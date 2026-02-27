FROM rocker/r-ver:4.3.2

# Instalar dependencias del sistema + certificados
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    build-essential \
    ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Configurar CRAN explícitamente
RUN echo "options(repos = c(CRAN = 'https://cloud.r-project.org/'))" >> /usr/local/lib/R/etc/Rprofile.site

# Instalar paquetes
RUN R -e "install.packages(c('shiny','shinydashboard','DT','ggplot2','plotly','vcd','reshape2'))"

# Crear carpeta app
WORKDIR /app

# Copiar app
COPY app.R /app/

# Exponer puerto
EXPOSE 3838

# Ejecutar app
CMD R -e "shiny::runApp('/app', host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')))"
