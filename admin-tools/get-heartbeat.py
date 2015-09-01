#!/bin/env python3
# -*- coding: utf-8 -*-

import json
import time

import memcache

mc = memcache.Client(['127.0.0.1'])

val = json.loads(mc.get('polaris_health:heartbeat'))
print(json.dumps(val, indent=4))

