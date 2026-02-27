FROM rocker/r-ver:4.3.2

# Instalar dependencias del sistema necesarias para plotly
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instalar paquetes R
RUN R -e "install.packages(c('shiny','shinydashboard','DT','ggplot2','plotly','vcd','reshape2'), repos='https://cloud.r-project.org/')"

# Crear directorio app
WORKDIR /app

# Copiar app
COPY app.R /app/

# Exponer puerto
EXPOSE 3838

# Ejecutar app usando puerto de Render
CMD R -e "shiny::runApp('/app', host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')))"
