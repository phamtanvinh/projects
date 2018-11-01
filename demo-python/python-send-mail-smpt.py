import smtplib
import ConfigParser

from email.mime.text import MIMEText
from email.MIMEMultipart import MIMEMultipart

config = ConfigParser.ConfigParser()
config.read('conf/email-config.ini')


from_addr = config.get('EMAIL','EMAIL_ADDR')
password = config.get('EMAIL', 'EMAIL_PASSWORD')
to_addr = 'phamtanvinh.me@gmail.com'
body = 'This is another test content'

msg = MIMEMultipart()
msg['From'] = from_addr
msg['To'] = to_addr
msg['Subject'] = 'Python test email with config'
msg.attach(MIMEText(body, 'plain'))

server = smtplib.SMTP('smtp.gmail.com', 587)
server.ehlo()
server.starttls()
server.ehlo()
server.login(from_addr, password)

server.sendmail(from_addr, to_addr, msg.as_string())