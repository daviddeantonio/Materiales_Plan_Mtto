#**********************************************************************************************
#  @Nombre: Materiales Plan de Mantenimiento
#  @Autor: David De Antonio
#  @Fecha: 20220119
#  @Cambios:
#  @Ayudas:
#**********************************************************************************************

# Cargue de Librerias -------------------------------------------------------------------------
library(tidyverse)    # Transformaciones de datos
library(data.table)   # Transformaciones de datos
library(lubridate)    # Tratamiento de fechas
library(httr)         # Publicacion de notificaciones
library(keyring)      # Manejo de contraseña
options(scipen = 999)

# Configuracion de ruta de archivos -----------------------------------------------------------
# Se configura que los archivos esten ubicados en la carpeta del share point de la DirMtto
usuario <- Sys.getenv("USERPROFILE")
sharepoint <- "\\greenmovil.com.co\\Gestion Mantenimiento - General\\"
ruta_from <- "Documentos\\03 Planeacion\\01 Modelos_Desgaste\\02 Insumos\\"
ruta_to <- "Documentos\\10 Datos\\"

# Cargue de Documentos de referencia ----------------------------------------------------------
# Ubicacion de los archivos
file_from <- str_c(usuario, sharepoint, ruta_from)
file_to <- str_c(usuario, sharepoint, ruta_to)
password <- key_get("melius", "modelo")

# Definir los nombres de los archivos para el escenario
plan_mat <- "20211221_Materiales_Plan.xlsx"
plan_nombre <- "20211027_plan_mtto.csv"
adf_nombre <- "20220120_ADF.csv"

## Plan Mtto para realizar la inclusion de los materiales -------------------------------------
plan_mtto <- read.csv(str_c(file_from, plan_nombre)) %>%
  select(c("codigo_reparacion", "Sistema", "Frecuencia", "tipo_medidor",
           "IdActividad", "Actividad", "Tiempo", "Tecnico", "Costo", "CPK", "Mxm"))

materiales_plan <- readxl::read_excel(str_c(file_from, plan_mat)) %>%
  janitor::clean_names(., case = c("upper_camel")) %>% 
  select(c("Codigo", "Descripcion", "PrecioCopIva","Cantidad", "Unidad", "IdActividad"))
  
data_pmm <- plan_mtto %>% 
  left_join(materiales_plan, by = "IdActividad")

# Iteracion de procesamiento de los modelos para descargar y analisis--------------------------
modelo_adf <- read.csv(str_c(file_from, adf_nombre)) %>% 
  janitor::clean_names(., case = c("upper_camel"))

materiales_adf <- modelo_adf %>% 
  left_join(data_pmm, by = c("ActividadDeMtto" = "codigo_reparacion"))

# Se cuadra el nombre del archivo de ADF con la incluision de los materiales ------------------

arrow::write_parquet(materiales_adf, str_c(usuario, sharepoint, ruta_to, "FactMat.parquet"))
  


