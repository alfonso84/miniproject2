import logging
import time
from flask import Flask, render_template
from logging import Logger, FileHandler, Formatter
from threading import Thread


app = Flask(__name__)

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

# Creamos un manejador de archivos para los logs
handler = FileHandler("logs.log", "w")
handler.setLevel(logging.DEBUG)
handler.setFormatter(Formatter("%(asctime)s - %(levelname)s - %(message)s"))
logger.addHandler(handler)


def write_logs():
    while True:
        # Imprimimos un mensaje de INFO
        logger.info("Mensaje de INFO")

        # Imprimimos un mensaje de WARNING
        logger.warning("Mensaje de WARNING")

        # Imprimimos un mensaje de ERROR
        logger.error("Mensaje de ERROR")

        # Retardamos la ejecución del siguiente iteración del bucle
        time.sleep(2)


# Creamos un hilo que ejecuta el write_logs
thread = Thread(target=write_logs)
thread.daemon = True
thread.start()


if __name__ == "__main__":
    # Hacemos que el Flask demonio se inicie en segundo plano
    app.run(debug=False, port=8000)