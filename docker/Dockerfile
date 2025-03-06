FROM os-harbor-svc.default.svc.cloudos:443/helm/h3ccloud/cicd/nginx:1.17.1-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY test.txt /etc/static/dist/index.html
COPY systemctl /user/systemct
RUN mkdir -p /usr/local/nginx/logs/ 
RUN chmod 755 /etc/nginx/nginx.conf
ENTRYPOINT ["/usr/sbin/nginx"]
CMD ["-g","daemon off;"]
