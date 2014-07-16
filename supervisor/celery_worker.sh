#!/bin/bash

# exit immediately if a command exits with a nonzero exit status.
set -e

{% set listen_address = postgres_settings.get('listen_address') -%}
{% set stripe_publish_key = settings.get('stripe_publish_key', None) -%}
{% if listen_address == 'localhost' -%}
DB_IP=; export DB_IP
{% else -%}
DB_IP={{ listen_address }}; export DB_IP
{% endif -%}
{% if settings.get('lan', None) -%}
ALLOWED_HOSTS="*"; export ALLOWED_HOSTS
{% else -%}
ALLOWED_HOSTS="{{ settings['domain'] }}"; export ALLOWED_HOSTS
{% endif -%}
DB_PASS="{{ settings['db_pass'] }}"; export DB_PASS
DJANGO_SETTINGS_MODULE="settings.production"; export DJANGO_SETTINGS_MODULE
DOMAIN="{{ settings['domain'] }}"; export DOMAIN
FTP_STATIC_DIR="/home/web/repo/ftp/{{ site }}/site/static"; export FTP_STATIC_URL
FTP_STATIC_URL="/fs/"; export FTP_STATIC_URL
FTP_TEMPLATE_DIR="/home/web/repo/ftp/{{ site }}/site/templates"; export FTP_TEMPLATE_DIR
MEDIA_ROOT="/home/web/repo/files/{{ site }}/public/"; export MEDIA_ROOT
{% if stripe_publish_key -%}
STRIPE_PUBLISH_KEY="{{ stripe_publish_key }}"; export STRIPE_PUBLISH_KEY
STRIPE_SECRET_KEY="{{ settings['stripe_secret_key'] }}"; export STRIPE_SECRET_KEY
{% endif -%}
SECRET_KEY="{{ settings['secret_key'] }}"; export SECRET_KEY
SENDFILE_ROOT="/home/web/repo/files/{{ site }}/private/"; export SENDFILE_ROOT
SSL="{{ settings['ssl'] }}"; export SSL

# mail configuration
{% set site_mail = settings.get('mail', {}) -%}
{% set mailgun_receive = site_mail.get('mailgun_receive', None) -%}
{% set mailgun_send = site_mail.get('mailgun_send', None) -%}
{% set mandrill_api_key = site_mail.get('mandrill_api_key', None) -%}
{% set mandrill_user_name = site_mail.get('mandrill_user_name', None) -%}
{% set mail = pillar.get('mail', {}) -%}
{% if mailgun_receive or mailgun_send -%}
{% set mailgun_domain = site_mail.get('mailgun_domain', None) -%}
{% if not mailgun_domain -%}
{% set mailgun_domain = settings.get('domain', None) -%}
{% endif -%}
# mailgun send and receive
MAILGUN_ACCESS_KEY="{{ mail['mailgun_access_key'] }}"; export MAILGUN_ACCESS_KEY
{% endif -%}
{% if mailgun_send -%}
MAILGUN_SERVER_NAME="{{ mailgun_domain }}"; export MAILGUN_SERVER_NAME
{% endif -%}
{% if mandrill_api_key -%}
MANDRILL_API_KEY="{{ mandrill_api_key }}"; export MANDRILL_API_KEY
{% endif -%}
{% if mandrill_user_name -%}
MANDRILL_USER_NAME="{{ mandrill_user_name }}"; export MANDRILL_USER_NAME
{% endif -%}

# captcha config
{% set captcha = pillar.get('captcha', {}) -%}
{% if captcha -%}
RECAPTCHA_PRIVATE_KEY="{{ captcha['recaptcha_private_key'] }}"; export RECAPTCHA_PUBLIC_KEY
RECAPTCHA_PUBLIC_KEY="{{ captcha['recaptcha_public_key'] }}"; export RECAPTCHA_PUBLIC_KEY
{% endif -%}

# amazon config
{% set amazon = pillar.get('amazon', {}) -%}
{% if amazon -%}
AWS_S3_ACCESS_KEY_ID="{{ amazon['aws_s3_access_key_id'] }}"; export AWS_S3_ACCESS_KEY_ID
AWS_S3_SECRET_ACCESS_KEY="{{ amazon['aws_s3_secret_access_key'] }}"; export AWS_S3_SECRET_ACCESS_KEY
{% endif -%}

cd /home/web/repo/project/{{ site }}/live/
/home/web/repo/project/activ8rlives_com/live/venv/bin/celery -A project worker --loglevel=info
