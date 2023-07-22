# # `python-base` sets up all our shared environment variables
# FROM python:3.11-slim as python-base

# # python
# ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 \
# # pip
#     PIP_NO_CACHE_DIR=on \
#     PIP_DISABLE_PIP_VERSION_CHECK=on \
#     PIP_DEFAULT_TIMEOUT=100 \
# # poetry
#     # https://python-poetry.org/docs/configuration/#using-environment-variables
#     POETRY_VERSION=1.5.1 \
#     POETRY_HOME="/opt/poetry" \
#     POETRY_VIRTUALENVS_IN_PROJECT=true \
#     POETRY_NO_INTERACTION=1 \
# # paths
#     PYSETUP_PATH="/opt/pysetup" \
#     VENV_PATH="/opt/pysetup/.venv"

# # prepend poetry and venv to path
# ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# # deps for installing poetry and deps for building python deps
# RUN apt-get update \
#     && apt-get install --no-install-recommends -y curl build-essential \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# # install poetry - respects $POETRY_VERSION & $POETRY_HOME
# RUN curl -sSL https://install.python-poetry.org | python3 -

# # install postgres dependencies inside of Docker
# RUN apt-get update \
#     && apt-get -y install libpq-dev gcc \
#     && pip install psycopg2 \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# # copy project requirement files here to ensure they will be cached.
# WORKDIR $PYSETUP_PATH
# COPY poetry.lock pyproject.toml ./

# # install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
# RUN poetry install --no-dev

# # quicker install as runtime deps are already installed
# RUN poetry install

# WORKDIR /app

# COPY . /app/

# EXPOSE 8000

# CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver bookstore-api-81fl.onrender.com"]





# # Use a imagem Python como base
# FROM python:3.11-slim

# # Configurar as variáveis de ambiente
# ENV PYTHONUNBUFFERED 1
# ENV PYTHONDONTWRITEBYTECODE 1

# # Configurar o diretório de trabalho
# WORKDIR /app

# # Copiar os arquivos de dependência e instalar as dependências
# COPY poetry.lock pyproject.toml ./
# RUN pip install --no-cache-dir poetry && poetry config virtualenvs.create false && poetry install --no-dev

# # Copiar o restante do código da aplicação
# COPY . /app/

# EXPOSE 8000

# # Comando para iniciar a aplicação usando Gunicorn
# CMD ["sh", "-c", "python manage.py migrate && gunicorn bookstore.wsgi:application --bind 0.0.0.0:8000"]



FROM python:3.11-slim

# Configurar as variáveis de ambiente
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# Configurar o diretório de trabalho
WORKDIR /app

# Copiar os arquivos de dependência e instalar as dependências
COPY poetry.lock pyproject.toml ./
RUN pip install --no-cache-dir poetry && poetry config virtualenvs.create false && poetry install --no-dev

# Copiar o restante do código da aplicação
COPY . /app/

EXPOSE 8000

# Rodar as migrações e criar o superusuário antes de iniciar o servidor Gunicorn
RUN python manage.py migrate
RUN echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'adminpass')" | python manage.py shell

# Comando para iniciar a aplicação usando Gunicorn
CMD ["gunicorn", "bookstore.wsgi:application", "--bind", "0.0.0.0:8000"]
