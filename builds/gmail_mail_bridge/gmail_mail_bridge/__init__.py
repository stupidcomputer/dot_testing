from flask import Flask
from flask import request
from flask import redirect
from flask import abort

import logging

import smtplib
import email

from subprocess import Popen, PIPE, STDOUT

pre_shared_secret = "amongus sussy imposter"
to = "ryan@beepboop.systems"

app = Flask(__name__)

def handle_post(request):
    msg = email.message_from_string(request.form["payload"])
    del msg["To"]
    msg["To"] = to
    if not msg["From"]:
        msg["From"] = "unknown-sender@mail.beepboop.systems"

    s = smtplib.SMTP('localhost')
    s.send_message(msg)
    s.quit()

@app.route("/bridge-submit", methods = ["GET", "POST"])
def testing():
    if request.method == 'POST':
        data = request.form
        if data['auth'] == pre_shared_secret:
            handle_post(request)
    else:
        return 'you didn\'t use post'
    return "default answer"
