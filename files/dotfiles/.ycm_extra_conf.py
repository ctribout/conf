#! /usr/bin/env python

import glob
import json
import logging
import os
import re
import subprocess
import sys

# Customizable parameters

# Folder names where compilation_commands.json can be found in source code
# repositories (either cmake build folders or folders where bear is run)
CMAKE_BUILD_DIRS = [".", ".build.cmake", "build", "linux", "clang"]
# Source code mapping: if a file is not found, try to locate it according to
# these rules (ex.: multi-repositories single compilation)
DIRS_REMAPPINGS = []

SOURCE_EXTENSIONS = [".cpp", ".cxx", ".cc", ".c", ".m", ".mm"]

# Extra flags added for specific extensions
EXTRA_FLAGS_FOR_EXT = {}

# Logs verbosity
DEBUG = False

# Allow to overwrite the local configuration up to now
LOCAL_CONF = __file__ + ".local"
if os.path.isfile(LOCAL_CONF):
    import imp
    local = imp.load_source("local", LOCAL_CONF)
    local.local_conf(globals(), locals())


# Other parameters

_HERE = os.path.dirname(os.path.abspath(__file__))
_RE_TYPE = type(re.compile(""))

# Extra flags related to the compilers, automatically populated when first requested
_EXTRA_FLAGS_FOR_COMPILER = {}
# List of commands to retrieve the default include paths from compilers
_COMPILERS_INC_CMDARGS = {
    (".c", ): [
        ["-Wp,-v", "-x", "c", "-", "-fsyntax-only"],
    ],
    (".cpp", ".c++", ".cc"): [
        ["-Wp,-v", "-x", "c++", "-", "-fsyntax-only"],
    ],
}

logging.basicConfig()
LOG = logging.getLogger("ycm")
_FMT = logging.Formatter("%(asctime)-15s %(levelname)s %(process)d %(message)s")
_HDL = logging.FileHandler(filename="/tmp/ycm_ct.log", mode="a")
_HDL.setFormatter(_FMT)
LOG.addHandler(_HDL)
if DEBUG:
    LOG.setLevel(logging.DEBUG)

FILE_DB = {}

def get_extra_flags(filename, compiler_flags):
    """ Add extra flags for a specific filename, either hardcoded (based on
    its extension), or using the compiler (ex.: for default include paths) """
    found = set()

    # Extension specific
    extension = os.path.splitext(filename)[1]
    found.update(EXTRA_FLAGS_FOR_EXT.get(extension, []))

    # Compiler specific
    compiler_path = compiler_flags[0]
    if not os.path.isfile(compiler_path):
        return []
    if compiler_path not in _EXTRA_FLAGS_FOR_COMPILER:
        for extensions, arglists in _COMPILERS_INC_CMDARGS.items():
            if extension not in extensions:
                continue
            for arglist in arglists:
                res = ""
                try:
                    res = subprocess.check_output(
                        [compiler_path] + arglist,
                        stdin=None,
                        stderr=subprocess.STDOUT,
                        shell=None,
                    )
                except subprocess.CalledProcessError as xxx:
                    res = xxx.output
                for line in res.decode("utf-8").splitlines():
                    line = line.strip()
                    if "inc" not in line:
                        continue
                    if line.startswith("/") and os.path.isdir(line):
                        found.add("-isystem {}".format(line))
                break
            if found:
                break
        if found:
            LOG.debug("Extra args for {}: {}".format(compiler_path, found))
            _EXTRA_FLAGS_FOR_COMPILER[compiler_path] = found
    found.update(_EXTRA_FLAGS_FOR_COMPILER.get(compiler_path, []))

    res = sorted(flag for flag in found if flag not in compiler_flags)
    if res:
        LOG.debug("Found extra flags for {}: {}".format(filename, res))
    return res


def make_relative_paths_in_flags_absolute(flags, working_directory):
    if not working_directory:
        return list(flags)
    new_flags = []
    make_next_absolute = False
    path_flags = ["-isystem", "-I", "-iquote", "--sysroot="]
    for flag in flags:
        new_flag = flag

        if make_next_absolute:
            make_next_absolute = False
            if not flag.startswith("/"):
                new_flag = os.path.join(working_directory, flag)

        for path_flag in path_flags:
            if flag == path_flag:
                make_next_absolute = True
                break

            if flag.startswith(path_flag):
                path = flag[len(path_flag) :]
                new_flag = path_flag + os.path.join(working_directory, path)
                break

        if new_flag:
            new_flags.append(new_flag)
    return new_flags


def is_header_file(filename):
    extension = os.path.splitext(filename)[1]
    return extension in (".h", ".hxx", ".hpp", ".hh", ".inline", ".inl")


def find_header_source_file(filename):
    """ Find a source code file corresponding to the input header file """

    LOG.debug("Trying to find source file for header {}".format(filename))
    basename = os.path.splitext(filename)[0]
    dirname = os.path.dirname(filename)
    found = None
    for extension in SOURCE_EXTENSIONS:
        matching_src_file = basename + extension
        if os.path.isfile(matching_src_file):
            found = matching_src_file
            break
    if not found:
        # Try to find in a "src" folder up one level, for cases where source
        # code is organized as modules with api/ and a src/ folders
        for extension in SOURCE_EXTENSIONS:
            matching_src_file = os.path.join(
                dirname, "..", "src", basename + extension)
            if os.path.isfile(matching_src_file):
                found = matching_src_file
                break

    if found:
        LOG.debug("Found corresponding source file for {} at {}".format(
            filename, found))
        return found

    LOG.debug("No source file for {}".format(filename))
    return None


def find_any_source_file(dirname):
    """ Find any source file in a given path, as a last resort solution. Check
    the parents as well, if nothing is found here """

    if dirname in (_HERE, "", "/"):
        # Already in the top-level folder: definitely give up now
        return None

    patterns = [
        os.path.join(dirname, "*" + extension)
        for extension in SOURCE_EXTENSIONS
    ]
    patterns += [
        os.path.join(os.path.dirname(dirname), "src", "*" + extension)
        for extension in SOURCE_EXTENSIONS
    ]
    for pattern in patterns:
        files = glob.glob(pattern)
        if files:
            return files[0]

    return find_any_source_file(os.path.dirname(dirname))


def get_compilation_info_for_file(database, filename):
    """ Retrieve the compilation info object from the ycm database """

    if is_header_file(filename):
        # The compilation_commands.json file generated by CMake does not have entries
        # for header files. So we do our best by asking the db for flags for a
        # corresponding source file, if any. If one exists, the flags for that file
        # should be good enough.
        sourcefile = find_header_source_file(filename)
    else:
        sourcefile = filename

    # Faithfhul attempt: directly ask the database about the file path found
    if sourcefile:
        compilation_info = database.GetCompilationInfoForFile(sourcefile)
        if compilation_info.compiler_flags_:
            LOG.debug("Found compilation info for file {}".format(sourcefile))
            return compilation_info

    # Nothing found: check for any source file in the expected path; the
    # flags should be pretty much the same
    sourcefile = find_any_source_file(os.path.dirname(filename))
    if sourcefile:
        compilation_info = database.GetCompilationInfoForFile(sourcefile)
        if compilation_info.compiler_flags_:
            LOG.debug("Found compilation info for file {}".format(sourcefile))
            return compilation_info

    return None


def find_compilation_info(directory):
    """ Try to find a compile_commands.json related to a source code folder """

    if directory in (_HERE, "", "/"):
        # Already in the top-level folder: abort
        return None

    # Try to find in the usual cmake build folders
    for folder in CMAKE_BUILD_DIRS:
        path = os.path.join(directory, folder, "compile_commands.json")
        if os.path.isfile(path):
            LOG.debug("Found {}".format(path))
            return os.path.dirname(path)

    for lkup, repl in DIRS_REMAPPINGS:
        # Try to find mappings for the directory, and check there too
        if isinstance(lkup, str):
            if lkup in new:
                res = find_compilation_info(directory.replace(lkup, repl))
                if res:
                    return res
        elif isinstance(lkup, _RE_TYPE):
            mapped = lkup.sub(repl, directory)
            if mapped != directory:
                res = find_compilation_info(mapped)
                if res:
                    return res

    # Last option: check the parent folder
    return find_compilation_info(os.path.dirname(directory))


def Settings(**kwargs):
    # This is the entry point; this function is called by ycmd to produce flags
    # for a file

    LOG.debug("YCM call for {}".format(str(kwargs)))

    filename = kwargs.get("filename", None)
    language = kwargs.get("language", None)

    if not filename or not language:
        return {}

    if language == "python":
        return {
            # 'interpreter_path': '~/project/virtual_env/bin/python',
            # 'sys_path': [] # paths to append to sys.path
        }

    elif language in ["cfamily", "c", "cpp"]:

        filename = os.path.abspath(filename)
        compile_info_dir = find_compilation_info(os.path.dirname(filename))

        if not compile_info_dir:
            LOG.debug("No database for file {}".format(filename))
            return {}

        if compile_info_dir not in FILE_DB:
            import ycm_core
            LOG.debug("Use database {} and cache it".format(compile_info_dir))
            database = ycm_core.CompilationDatabase(compile_info_dir)
            FILE_DB[compile_info_dir] = database
        else:
            LOG.debug("Use database {} from cache".format(compile_info_dir))
            database = FILE_DB[compile_info_dir]

        if not database:
            LOG.debug("No database found")
            return {}

        compilation_info = get_compilation_info_for_file(database, filename)
        if not compilation_info:
            with open(os.path.join(compile_info_dir, "compile_commands.json")) as fhl:
                j = json.load(fhl)
                ffilename = j[0]["file"]
                LOG.debug("First file name: {}".format(ffilename))
                compilation_info = get_compilation_info_for_file(database, ffilename)

        if not compilation_info:
            LOG.debug("No compilation info for file {}".format(filename))
            return {}

        flags = make_relative_paths_in_flags_absolute(
            compilation_info.compiler_flags_,
            compilation_info.compiler_working_dir_,
        )
        flags += get_extra_flags(filename, flags)

        LOG.debug("Found flags info for file {}: {}".format(filename, flags))

        # See https://github.com/ycm-core/ycmd/blob/master/README.md#settings-kwargs-
        return {
            "flags": flags,
            "flags_ready": True,
            "do_cache": True,
            # "include_paths_relative_to_dir": "",
            # "override_filename": "",
        }

    return {}

