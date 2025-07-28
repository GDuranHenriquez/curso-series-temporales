library(forecast)
library(tseries)
# Dataset de linces 
# N?mero de linces atrapados por a?o en el per?odo 1821-1934 en Canad?
length(lynx)

plot(lynx)

# Parece estacionario pero probablemente haya autocorrelaci?n 
# Si se capturan muchos linces un a?o, se espera que al ?o sgte hayan menos porque hay menos para reproducirse.
# Vemos un pulso c?clico que son los puntos m?ximos, no hay estacionalidad pero hay un patr?n

# Es estacionaria
adf.test(lynx)



tsdisplay(lynx) # autoregresion?

#Por lo menos un AR(2)

auto.arima(lynx) # version basica

auto.arima(lynx, trace = T)

# Mejor modelo
myarima=auto.arima(lynx, trace = T, 
           stepwise = F, 
           approximation = F)
#Obtén el valor del logaritmo de la verosimilitud (LL) y el AIC para el modelo AR(4) que estimamos con auto.arima.
ll_aic = c(myarima$loglik, myarima$aic)
ll_aic

#> myarima
#considera hasta el orden 4

#¿Recuerdas la función de autocorrelación parcial? ¿Cuál era el último retraso que salía significativo?
# Resp. El ultimo retrazo significativo era el 8vo.

# Según la documentación de auto.arima, los órdenes máximos que se consideran por defecto son:
# max.p = 5 y max.q = 5. Esto explica por qué el modelo no explora órdenes mayores,
# a menos que se especifique un límite mayor manualmente.

myarima=auto.arima(lynx, trace = T, stepwise = F, approximation = F, max.order=8, max.p=8)
# Best model: ARIMA(8,0,0) with non-zero mean
ll_aic_8_0_0 = c(myarima$loglik, myarima$aic)
ll_aic_8_0_0
ll_aic
# Si consideramos el modelo de menor LL y mayor AIC, nos quedariamos con el modelo ARIMA(8,0,0), 
#ya esta comparación indica que es mejor modelo.

### ARIMA Forecast
# Forecast de 10 a?os
arimafore <- forecast(myarima, h = 10)

plot(arimafore)

# Valores estimados del futuro
arimafore$mean

# Ultimas observaciones y forecast
plot(arimafore, xlim = c(1930, 1944))



