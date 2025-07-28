# Modelo Predictivo para Trading Manual con Temporalidad Dual (15min + 1h)

## **1. Objetivo**
Combinar datos en **15min** (timing preciso) y **1h** (filtro de tendencia) para:
- **Aumentar probabilidad de acierto** (evitar operar contra tendencia).
- **Reducir ruido** en señales de corto plazo.

---

## **2. Pipeline Recomendado**

### **A. Descarga de Datos**
```python
from binance.client import Client
import pandas as pd

# Configuración API Binance
client = Client(api_key, api_secret)

# Descargar datos en 15min
data_15m = client.get_klines(symbol="BTCUSDT", interval=Client.KLINE_INTERVAL_15MINUTE, limit=5000)
df_15m = pd.DataFrame(data_15m, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
df_15m['timestamp'] = pd.to_datetime(df_15m['timestamp'], unit='ms')

# Descargar datos en 1h
data_1h = client.get_klines(symbol="BTCUSDT", interval=Client.KLINE_INTERVAL_1HOUR, limit=1000)
df_1h = pd.DataFrame(data_1h, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
df_1h['timestamp'] = pd.to_datetime(df_1h['timestamp'], unit='ms')


B. Feature Engineering
Para 15min (Señales de Entrada)
# Ejemplo: RSI y EMA12
df_15m['rsi_14'] = ta.RSI(df_15m['close'], timeperiod=14)
df_15m['ema_12'] = ta.EMA(df_15m['close'], timeperiod=12)

Para 1h (Tendencia)
# Ejemplo: SMA50 y MACD
df_1h['sma_50'] = ta.SMA(df_1h['close'], timeperiod=50)
df_1h['macd'], _, _ = ta.MACD(df_1h['close'])

Alineación Temporal
Regla crítica: Los datos de 1h deben usarse solo hasta la vela cerrada más reciente para evitar look-ahead bias.
# Ejemplo: Alinear datos cada vez que se opera en 15min
def align_data(df_15m, df_1h):
    df_15m['tendencia_1h'] = df_15m['timestamp'].apply(
        lambda x: df_1h[df_1h['timestamp'] <= x].iloc[-1]['sma_50']
    )
    return df_15m

Modelado
A. Modelo para 15min (Clasificación Binaria)
from sklearn.ensemble import RandomForestClassifier

# Target: 1 si el precio sube en las próximas 3 velas (45min)
df_15m['target'] = (df_15m['close'].shift(-3) > df_15m['close']).astype(int)

# Entrenamiento
model_15m = RandomForestClassifier()
model_15m.fit(df_15m[['rsi_14', 'ema_12', 'volume']], df_15m['target'])

B. Modelo para 1h (Tendencia)
# Target: 1 si SMA50 > SMA200 (tendencia alcista)
df_1h['sma_200'] = ta.SMA(df_1h['close'], timeperiod=200)
df_1h['target_trend'] = (df_1h['sma_50'] > df_1h['sma_200']).astype(int)

model_1h = RandomForestClassifier()
model_1h.fit(df_1h[['sma_50', 'macd']], df_1h['target_trend'])

Ejecución de Señales
def generate_signal(df_15m, df_1h):
    # Predicciones
    df_15m['signal_15m'] = model_15m.predict(df_15m[['rsi_14', 'ema_12', 'volume']])
    df_15m['trend_1h'] = df_15m['timestamp'].apply(
        lambda x: model_1h.predict(df_1h[df_1h['timestamp'] <= x].iloc[-1][['sma_50', 'macd']].values.reshape(1, -1))
    
    # Señal final (ambos modelos alineados)
    df_15m['final_signal'] = (df_15m['signal_15m'] == 1) & (df_15m['trend_1h'] == 1)
    return df_15m

Backtesting
# Métricas clave
win_rate = (df_15m[df_15m['final_signal']]['target'].mean()) * 100
profit_factor = (ganancias_perdidas_positivas.sum() / abs(ganancias_perdidas_negativas.sum()))

print(f"Win Rate: {win_rate:.2f}%")
print(f"Profit Factor: {profit_factor:.2f}")


Gestión de Riesgo
Tamaño de posición: 1-2% si final_signal=True, 0% en otro caso.

Stop-loss:

0.8% para 15min.

1.5% si la tendencia en 1h es neutral.


---

### **Notas Clave**
1. **15min**:  
   - Enfoque en **RSI**, **EMA12-26**, y volumen.  
   - Predecir movimientos en **45-90min**.  

2. **1h**:  
   - Confirmar con **SMA50/200** y **MACD**.  
   - Evitar operar si la tendencia es bajista.  

3. **Backtesting**:  
   - Prioriza datos de **2023-2024** (incluye mercados bajistas y alcistas).  

¿Necesitas ajustar algún paso en específico?