# on-this-day

## Introduction

On This Day is a minimalist Vue3 application made for getting my hands dirty with DevOps methodolgoy and tooling.

## Table of Contents

- [on-this-day](#on-this-day)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Day 1 - Vue](#day-1---vue)
    - [Creating a minimalist Vue application](#creating-a-minimalist-vue-application)
    - [Notes](#notes)
  - [Day 2 - Docker](#day-2---docker)
    - [Dockerizing the Vue application](#dockerizing-the-vue-application)
    - [Notes](#notes-1)

## Day 1 - Vue

### Creating a minimalist Vue application

The birth of on-this-day application, I spent a day learning little bit of Vue3 and setting up minimum viable product that not only looked neat but also contained enough functionality for it to be classified as a web-application. I'll add more features as the journey continues.

Why Vue you ask? I just wanted something that required interacting with CLI in order to be able to use DevOps tools like Terraform, Github Actions, and AWS. And it isn't react so that's an added bonus.

### Notes

1. Instead of Vue CLI, I went for plain old `npm init vue@latest`

## Day 2 - Docker

### Dockerizing the Vue application

Successfully containerized the Vue application and made sure the pages were being served from the build, rather than the development environment. *And pushed it to Docker hub!*  

**TODO:** docker-compose


### Notes

1. Docker desktop is pretty nice
