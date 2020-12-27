from invoke import task


def black(c, check):
    cmd = f"black . --line-length=79 {'--check' if check is True else ''}"
    return c.run(cmd, pty=True)


@task(aliases=["f"])
def format(c):
    return black(c, False)


@task(aliases=["cf", "fc"])
def check_format(c):
    return black(c, True)


@task(aliases=["lp"])
def lint_python(c):
    return c.run("pycodestyle .", pty=True)


@task(aliases=["ls"])
def lint_shell(c):
    cmd = (
        "find . -type f \( -name '*.sh' -o -name '*.bats' \) "
        "! -path '*/submodules/*' | xargs shellcheck -x"
    )
    return c.run(cmd, pty=True)


@task(aliases=["l"], pre=[lint_shell, lint_python])
def lint(c):
    pass
