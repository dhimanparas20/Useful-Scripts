FROM openresty/openresty:1.19.9.1-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d
COPY backend/static /app/static/
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80