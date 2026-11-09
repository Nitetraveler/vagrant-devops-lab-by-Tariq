#!/usr/bin/env python3
"""Tiny JSON service used by the cluster lab (stdlib only)."""
import json
import os
import socket
from http.server import BaseHTTPRequestHandler, HTTPServer

NODE = os.environ.get("APP_NODE", socket.gethostname())
VERSION = os.environ.get("APP_VERSION", "1.0")
COLOR = os.environ.get("APP_COLOR", "none")
PORT = int(os.environ.get("APP_PORT", "5000"))


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/healthz":
            body, ctype = b"ok\n", "text/plain"
        else:
            payload = {"node": NODE, "version": VERSION, "color": COLOR, "path": self.path}
            body, ctype = (json.dumps(payload) + "\n").encode(), "application/json"
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
