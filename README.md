# Bookstore

Bookstore API using Django, Django Rest Framework and Docker.

## Prerequisites

```
Python 3.11>
Poetry
Docker && docker-compose

```

## Quickstart

1. Clone this project

   ```shell
   git clone git@github.com:jose-uchoa/bookstore.git
   ```

2. Install dependencies:

   ```shell
   cd bookstore
   poetry install
   ```

3. Run local dev server:

   ```shell
   poetry run python manage.py migrate
   poetry run python manage.py runserver
   ```

   3.1 - To access the views, go to the routes "/bookstore/v1/product/" or "/bookstore/v1/order/" on your local address.

4. Run docker dev server environment:

   ```shell
   docker-compose up -d --build
   ```

   4.1 - To access the views, go to the routes "/bookstore/v1/product/" or "/bookstore/v1/order/" on your local address.

5. Run tests inside of docker:

   ```shell
   docker-compose exec web pytest
   ```
