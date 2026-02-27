FROM rocker/shiny:latest

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instalar paquetes R necesarios
RUN R -e "install.packages(c('shiny','shinydashboard','DT','ggplot2','plotly','vcd','reshape2'), repos='https://cloud.r-project.org/')"

# Copiar app
WORKDIR /app
COPY app.R /app/

# Exponer puerto (Render lo asigna dinámicamente)
EXPOSE 3838

# Ejecutar app directamente (NO shiny-server)
CMD R -e "shiny::runApp('/app', host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')))"
