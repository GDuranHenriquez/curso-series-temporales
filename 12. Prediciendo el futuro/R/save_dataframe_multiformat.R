
save_data <- function(dataframe){
  if (!require(openxlsx)) install.packages("openxlsx")
  library(openxlsx)
  
  # Ruta base para guardar
  ruta_base <- "btc_data"
  
  # 1. Guardar como TXT delimitado por tabulaciones
  cat("1. Guardar como TXT delimitado por tabulaciones. \n")
  write.table(btc_data,
              file = paste0(ruta_base, ".txt"),
              sep = "\t",
              row.names = FALSE,
              quote = FALSE)
  
  # 2. Guardar como CSV
  #write.csv(btc_data,
            #file = paste0(ruta_base, ".csv"),
            #row.names = FALSE)
  
  # 3. Guardar como archivo RDS (formato binario de R)
  cat("2. Guardar como archivo RDS (formato binario de R). \n")
  saveRDS(btc_data, file = paste0(ruta_base, ".rds"))
  
  # 4. Guardar como archivo Excel (.xlsx)
  # Si el archivo es muy grande, openxlsx lo maneja mejor que writexl o readxl
  #write.xlsx(btc_data, file = paste0(ruta_base, ".xlsx"), asTable = TRUE)
  
  cat("Todos los archivos han sido guardados correctamente.\n")
}