from invoke import task, Result
from invoke.exceptions import UnexpectedExit


def black(c, check):
    cmd = f"black . --line-length=79 {'--check' if check is True else ''}"
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
        "for file in $(find . -type f \\( -name '*.bats' \\) "
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
    return shfmt_bats(c, True)


@task(aliases=["fss"])
def format_shell_sh(c):
    return shfmt_sh(c, False)


@task(aliases=["cfss", "fcss"])
def check_format_shell_sh(c):
    return shfmt_sh(c, True)


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
    return c.run("pycodestyle .", pty=True)


@task(aliases=["ls"])
def lint_shell(c):
    cmd = (
        "find . -type f \\( -name '*.sh' -o -name '*.bats' \\) "
        "! -path '*/submodules/*' | xargs shellcheck -x"
    )
    return c.run(cmd, pty=True)


@task(aliases=["l"])
def lint(c):
    shell_succeeded = True
    try:
        lint_shell(c)
        print("ShellCheck completed successfully")
    except UnexpectedExit as err:
        shell_succeeded = False

    python_succeeded = True
    try:
        lint_python(c)
        print("Pycodestyle completed successfully")
    except UnexpectedExit as err:
        python_succeeded = False

    if not shell_succeeded or not python_succeeded:
        raise UnexpectedExit(Result(command="lint", exited=1))
