FROM ubuntu:20.04

LABEL maintainer="Maximo Miranda"

# Use bash instead of sh.
SHELL ["/bin/bash", "-c"]

# System
RUN apt-get update \
    && apt-get -y install software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y apache2 curl supervisor zip libpng-dev ca-certificates \
    # Additional Package
    && apt-get install -y php8.1-common php8.1-gd php8.1-imap php8.1-soap php8.1-redis php8.1-intl php8.1-readline php8.1-ldap php8.1-msgpack php8.1-igbinary \
    # Laravel Requirements
    && apt-get install -y libapache2-mod-php8.1 php8.1-dev php8.1-curl php8.1-pgsql php8.1-xml php8.1-cli  \
    && apt-get install -y  php8.1-zip php8.1-bcmath php8.1-mbstring php8.1-opcache php8.1-imagick \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Application
COPY . /var/www/html/

# Supervisor
COPY k8s/services/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY k8s/services/supervisord/start-apache-supervisor /usr/local/bin/start-apache-supervisor
RUN chmod +x /usr/local/bin/start-apache-supervisor

# Apache
COPY k8s/services/laravel/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Dependencies
WORKDIR /var/www/html
RUN composer install --optimize-autoloader --no-dev

# Optimize Framework
RUN php artisan route:cache
RUN php artisan view:cache

# Permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 775 /var/www/html/storage
RUN a2enmod rewrite

EXPOSE 80

ENTRYPOINT ["start-apache-supervisor"]
