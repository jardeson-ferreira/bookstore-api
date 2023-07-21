# `python-base` sets up all our shared environment variables
FROM python:3.11.4-slim as python-base

# python
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 \
# pip
    PIP_NO_CACHE_DIR=on \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
# poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_VERSION=1.5.1 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
# paths
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# deps for installing poetry and deps for building python deps
RUN apt-get update \
    && apt-get install --no-install-recommends -y curl && apt-get clean\
    && apt-get install --no-install-recommends -y build-essential && apt-get clean\

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | python3 -

# install postgres dependencies inside of Docker
RUN apt-get update \
    && apt-get -y install libpq-dev && apt-get clean\
    && apt-get -y install gcc && apt-get clean\
    && pip install psycopg2

# copy project requirement files here to ensure they will be cached.
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN poetry install --no-dev

# quicker install as runtime deps are already installed
RUN poetry install

WORKDIR /app

COPY . /app/

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
