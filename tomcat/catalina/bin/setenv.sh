CLASSPATH=
LANG=nl
LC_ALL=nl_NL.iso88591
LC_CTYPE=iso88591
CATALINA_PID=$CATALINA_BASE/pid/tomcat.pid

# Set JAVA_OPTS memory size, only used for STOP because CATALINA_OPTS overrides for start and run (to avoid
# 'Could not reserve enough space for object heap' just when calling 'stop')
JAVA_OPTS="-Xmx16m -Djava.awt.headless=true"


CATALINA_OPTS=\
"-server\
 -Dapplication.server.type=TOMCAT10\
 -Dtransaction.strategy=JOTM\
 -Djava.rmi.server.hostname=localhost\
 -Djava.net.preferIPv4Stack=true\
 -Djava.awt.headless=true\
 -Dbuild.compiler.emacs=true\
 -Duser.language=nl -Duser.region=NL -Dfile.encoding=cp1252\
 -Dlog.dir=$CATALINA_BASE/logs\
 -Xmx1000m -Xms500m -Xss1024k \
 -XX:+PrintClassHistogram\
 -XX:+HeapDumpOnOutOfMemoryError\
 -XX:+UseConcMarkSweepGC\
 -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=true\
 -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true\
 -Dorg.apache.jasper.runtime.BodyContentImpl.USE_POOL=true\
 -XX:+TraceClassUnloading"
