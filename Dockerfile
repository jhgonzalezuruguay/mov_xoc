FROM rocker/shiny:latest

# Instalar dependencias del sistema si es necesario
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copiar la app
COPY app.R /srv/shiny-server/

# Copiar configuración de Shiny Server
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Instalar paquetes R necesarios
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'ggplot2', 'plotly', 'vcd', 'reshape2'), repos='http://cran.rstudio.com/')"

# Comando por defecto
CMD ["/usr/bin/shiny-server.sh"]
