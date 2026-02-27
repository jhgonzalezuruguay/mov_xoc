FROM rocker/shiny:latest

# Instalar dependencias del sistema si es necesario
RUN apt-get update && apt-get install -y \
    && rm -rf /var/lib/apt/lists/*

# Copiar la app
COPY app.R /srv/shiny-server/

# Instalar paquetes R necesarios
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'ggplot2', 'plotly', 'vcd', 'reshape2'))"

# Exponer puerto
EXPOSE 3838

# Comando por defecto
CMD ["/usr/bin/shiny-server.sh"]
