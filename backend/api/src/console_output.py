from logging import config, LogRecord
import re
from fastapi import FastAPI
from uvicorn.logging import AccessFormatter


class ColoredAccessFormatter(AccessFormatter):
    method_colors: dict[str, str] = {
        "GET": "\033[94m",    # Blue
        "PUT": "\033[93m",    # Yellow
        "DELETE": "\033[91m", # Red
        "POST": "\033[92m",   # Green
        "RESET": "\033[0m"    # Reset color
    }

    def format(self, record: LogRecord) -> str:
        return re.sub(
            r'(' + '|'.join(self.method_colors.keys()) + r' )',  # Match any of the method names
            lambda match: f'{self.method_colors[match.group()]}{match.group()}{self.method_colors["RESET"]}',  # Wrap the matched method name in color
            super().format(record)  # Call the parent class's format method
        )


# Configure custom logging
LOG_CONFIG = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "color_access": {
            "()": ColoredAccessFormatter,
            "fmt": "%(levelprefix)s %(client_addr)s - \"%(request_line)s\" %(status_code)s",
        }
    },
    "handlers": {
        "access": {
            "formatter": "color_access",
            "class": "logging.StreamHandler",
            "stream": "ext://sys.stderr",
        }
    },
    "loggers": {
        "uvicorn.access": {"handlers": ["access"], "level": "INFO", "propagate": False},
    }
}

    # from .console_output import LOG_CONFIG

def setup_logging(app: FastAPI):
    @app.on_event("startup")
    async def startup_event(): config.dictConfig(LOG_CONFIG)  # ^ Set the LOG_CONFIG as the logging config
