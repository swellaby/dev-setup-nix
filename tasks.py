from invoke import task, Result
from invoke.exceptions import UnexpectedExit
from os.path import dirname, abspath

root_dir = dirname(abspath(__file__))


def black(c, check):
    check_flag = f"{'--check' if check is True else ''}"
    cmd = f"black {root_dir} --line-length=79 {check_flag}"
    return c.run(cmd, pty=True)


@task(aliases=["fp"])
def format_python(c):
    return black(c, False)


@task(aliases=["cfp", "fcp"])
def check_format_python(c):
    return black(c, True)


def shfmt_bats(c, check):
    mode = f"{'-d' if check is True else '-w'}"
    cmd = (
        "result=0 && "
        f"for file in $(find {root_dir} -type f \\( -name '*.bats' \\) "
        "! -path '*/submodules/*'); do "
        f"shfmt {mode} -i 2 -ci --ln bats $file; "
        "if [ $? -ne 0 ]; then result=1; fi; done && "
        "exit $result"
    )
    return c.run(cmd, pty=True)


def shfmt_sh(c, check):
    cmd = f"shfmt {'-d' if check is True else '-w'} ."
    return c.run(cmd, pty=True)


@task(aliases=["fsb"])
def format_shell_bats(c):
    return shfmt_bats(c, False)


@task(aliases=["cfsb", "fcsb"])
def check_format_shell_bats(c):
    result = shfmt_bats(c, True)
    print("shfmt completed successfully for *.bats files")
    return result


@task(aliases=["fss"])
def format_shell_sh(c):
    return shfmt_sh(c, False)


@task(aliases=["cfss", "fcss"])
def check_format_shell_sh(c):
    result = shfmt_sh(c, True)
    print("shfmt completed successfully for *.sh files")
    return result


@task(aliases=["fs"], pre=[format_shell_sh, format_shell_bats])
def format_shell(c):
    pass


@task(aliases=["cfs", "fcs"])
def check_format_shell(c):
    sh_succeeded = True
    try:
        check_format_shell_sh(c)
    except UnexpectedExit as err:
        sh_succeeded = False

    bats_succeeded = True
    try:
        check_format_shell_bats(c)
    except UnexpectedExit as err:
        bats_succeeded = False

    if not sh_succeeded or not bats_succeeded:
        raise UnexpectedExit(Result(command="check_format_shell", exited=1))


@task(aliases=["f"], pre=[format_shell, format_python])
def format(c):
    pass


@task(aliases=["cf", "fc"])
def check_format(c):
    shell_succeeded = True
    try:
        check_format_shell(c)
    except UnexpectedExit as err:
        shell_succeeded = False

    python_succeeded = True
    try:
        check_format_python(c)
    except UnexpectedExit as err:
        python_succeeded = False

    if not shell_succeeded or not python_succeeded:
        raise UnexpectedExit(Result(command="check_format", exited=1))


@task(aliases=["lp"])
def lint_python(c):
    result = c.run(f"pycodestyle {root_dir}", pty=True)
    print("pycodestyle completed successfully")
    return result


@task(aliases=["ls"])
def lint_shell(c):
    cmd = (
        f"find {root_dir} -type f \\( -name '*.sh' -o -name '*.bats' \\) "
        f"! -path '*/submodules/*' | xargs shellcheck -x -P {root_dir}"
    )
    result = c.run(cmd, pty=True)
    print("ShellCheck completed successfully")
    return result


@task(aliases=["l"])
def lint(c):
    shell_succeeded = True
    try:
        lint_shell(c)
    except UnexpectedExit as err:
        shell_succeeded = False

    python_succeeded = True
    try:
        lint_python(c)
    except UnexpectedExit as err:
        python_succeeded = False

    if not shell_succeeded or not python_succeeded:
        raise UnexpectedExit(Result(command="lint", exited=1))
