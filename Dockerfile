FROM rocker/shiny:latest

# Copiar la app
COPY app.R /srv/shiny-server/

# Exponer el puerto
EXPOSE 3838

# Comando de inicio
CMD ["/usr/bin/shiny-server"]
