# cs198-api

[![Build Status](https://travis-ci.org/cs198/cs198-api.svg?branch=travis-ci)](https://travis-ci.org/cs198/cs198-api)

[Wiki](https://github.com/cs198/cs198-api/wiki)

The CS198 API is a JSON API built with Ruby on Rails. It provides all the data necessary for
CS198 frontend web applications to run, abstracting away the databases as a clean, RESTful API.

## Running the dev server

```bash
$ rails server
```

## Building

This runs tests and lint, to ensure that your code meets [quality
standards](https://github.com/cs198/cs198-api/wiki/contributing#code-quality-standards). This does
not, however, check if you have written tests in the first place!

```bash
$ rake
```

To run tests or lint in isolation, do:

```bash
$ rake test
$ rake lint
```

## How to contribute

We'd love to have you work with us; working on these tools really improves the section leader
program, and may provide you with valuable experience doing web software engineering.

### Background info

We rely on `git` and Ruby on Rails to run this system, so if you're not familiar with those tools
then getting familiar with them would be valuable. Any contributions you make here will be
code-reviewed, so if you're unsure if you're ready just contribute and we'll tell you how to
improve!

* [Pro-git](http://git-scm.com/book/en/v2) covers everything you need to know about `git`; I
    recommend going through most of this book.
* [Rails Guides](http://guides.rubyonrails.org/getting_started.html) is a good place to start
    learning about how Rails works.

### Project-specific tutorials

* [Set up your development environment](https://github.com/cs198/cs198-api/wiki/setup)
* [Try out the API](https://github.com/cs198/cs198-api/wiki/try-the-api)
* When you're ready to push, we use the [Github PR
workflow](https://github.com/cs198/cs198-api/wiki/contributing) to manage
contributions.

Thanks for your continued support!
