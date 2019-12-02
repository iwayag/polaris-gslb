#-*- coding: utf-8 -*-

import sys
import traceback


class Error(Exception):

    """Generic exception"""

    def __init__(self, *args, **kwargs):
        super(Error, self).__init__(*args, **kwargs)

        if sys.stdout.isatty():
            traceback.print_exc()


class ProtocolError(Error):

    """Protocol error, used by protocols"""

    pass


class MonitorFailed(Error):

    """Exception to signal health check failure, used by monitors"""

    pass

