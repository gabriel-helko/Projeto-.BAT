SET psw=23softin56
D:\mysqldump -h 10.0.0.113 -u softin --password=%psw% sp3 --result-file=D:\backup_spmaster\sp3_%DATE:/=.%_%TIME::=;%.sql
exit