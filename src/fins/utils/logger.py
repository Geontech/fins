"""This module includes helper logic for enabling colored logging.
The code in this file was originally adapted from:
    https://stackoverflow.com/questions/384076/how-can-i-color-python-logging-output

Import this module in main.py as follows:
    >>> import logging
    >>> from fins.utils import ColoredLogger
    >>> logging.setLoggerClass(ColoredLogger)
    >>> logging.getLogger().setLevel(logging.INFO)
    >>> LOGGER = logging.getLogger('fins')

Then, to set the log level globally for fins:
    >>> logging.getLogger().setLevel(logging.DEBUG)

And finally to use this colored logger:
    >>> LOGGER.debug('This is a colored debug print!')

Each module within fins can do the following to use this logger:
    >>> import logging
    >>> LOGGER = logging.getLogger(__name__)
"""

import logging

#These are the sequences need to get colored ouput
RESET_SEQ = "\u001b[0m"
COLOR_SEQ = "\u001b[38;5;%dm"
BOLD_SEQ  = "\u001b[1m"


def formatter_message(message, use_color=True):
    """Take an existing log format and convert it to color+bold if applicable
    """
    if use_color:
        message = message.replace("$RESET", RESET_SEQ).replace("$BOLD", BOLD_SEQ)
    else:
        message = message.replace("$RESET", "").replace("$BOLD", "")
    return message


DULL_BLUE = 68
DULL_GREEN = 64
YELLOW = 226
ORANGE = 208
RED = 196
WHITE = 15
PINK = 200

COLORS = {
    'INFO': DULL_GREEN,
    'DEBUG': DULL_BLUE,
    'WARNING': ORANGE,
    'ERROR': RED,
    'CRITICAL': PINK,
}


class ColoredFormatter(logging.Formatter):
    """Custom formatter for colored logging
    """

    def __init__(self, msg, use_color=True):
        logging.Formatter.__init__(self, msg)
        self.use_color = use_color

    def format(self, record):
        """Add color and boldness to a log record
        """
        if self.use_color and record.levelname in COLORS:
            levelname_color = BOLD_SEQ + COLOR_SEQ % COLORS[record.levelname] + record.levelname.ljust(8) + RESET_SEQ
            record.levelname = levelname_color
            name_color = BOLD_SEQ + COLOR_SEQ % DULL_GREEN + record.name + RESET_SEQ
            record.name = name_color
        #TODO change format based on log level
        return logging.Formatter.format(self, record)


class ColoredLogger(logging.Logger):
    """Custom logger class with multiple destinations
    """
    FORMAT = "[%(name)s:%(filename)s:%(lineno)-4s][%(levelname)s]$RESET  %(message)s"
    COLOR_FORMAT = formatter_message(FORMAT, True)

    def __init__(self, name):
        logging.Logger.__init__(self, name)

        color_formatter = ColoredFormatter(self.COLOR_FORMAT)

        console = logging.StreamHandler()
        console.setFormatter(color_formatter)

        self.addHandler(console)
        return
