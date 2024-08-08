# Nginx runtime as a base image
FROM nginxinc/nginx-unprivileged:stable-alpine

# Create a new user and group called 'nginx' with UID/GID 101
# RUN addgroup --system nginx \
#     && adduser --system --no-create-home --ingroup nginx --disabled-login nginx

# # Create a directory for the application files
# RUN mkdir /app

# # Change ownership of the directory to the 'nginx' user
# RUN chown nginx:nginx /usr/share/nginx/html
# RUN chown nginx:nginx /etc/nginx
# RUN chown nginx:nginx /var/lib
# RUN chown nginx:nginx /var/log
# RUN chown nginx:nginx /var/cache


# Copy index.html to the nginx web root directory
COPY certs /usr/share/nginx/html/certs
COPY css /usr/share/nginx/html/css
COPY fonts /usr/share/nginx/html/fonts
COPY images /usr/share/nginx/html/images
COPY dashboard.html /usr/share/nginx/html/dashboard.html
COPY global.js /usr/share/nginx/html/global.js
COPY index.html /usr/share/nginx/html

# Copy Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# simple health check to make sure app is up
HEALTHCHECK --interval=5m --timeout=3s CMD curl --fail http://localhost:8080 || exit 1

# Expose port 80 to allow outside access to our webpage
EXPOSE 8080
EXPOSE 8443

# Run nginx non-root
USER nginx
# Command to run Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
