import zeep


wsdl = 'http://98.191.211.169/xml/soapresponder.wsdl'
client = zeep.Client(wsdl=wsdl)
reponse = client.service.Method1('Vinhpt', 'Other')
print(dir(client))
print(reponse)
