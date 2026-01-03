#! /bin/bash

CLASSPATH=
LANG=nl
LC_ALL=nl_NL.iso88591
LC_CTYPE=iso88591

# find out limit of current pod:
#limit=`cat /sys/fs/cgroup/memory/memory.limit_in_bytes`
# Substract 1.5G some for non heap useage
#heapsize=$((limit - 1500000000))

if [ -z "$MaxRAMPercentage" ] ; then
  MaxRAMPercentage=75.0
fi

# memory options
# -XX:MaxRAMPercentage=${MaxRAMPercentage}
# -XX:+UseContainerSupport                      Default, but lets be explicit, we target running in a container.
# -XX:+UseZGC

if [ -z "$GarbageCollectionOption" ] ; then
  GarbageCollectionOption=-XX:+UseG1GC
  # GarbageCollectionOption=-XX:+UseZGC
fi

export CATALINA_OPTS="$CATALINA_OPTS ${GarbageCollectionOption} -XX:MaxRAMPercentage=${MaxRAMPercentage} -XshowSettings:vm -XX:+UseContainerSupport"



# Heap dumps may be quite large, if you need to create them on out of memory, start the pod with environment variable HeapDumpPath=/data (or so)
if [ ! -z "$HeapDumpPath" ] ; then
  mkdir -p "${HeapDumpPath}"
  if chmod 775 "${HeapDumpPath}" 2>/dev/null; then
    : # success
  else
    # chmod failed; common causes: /data is a bind-mounted host dir, an NFS mount, or the process lacks privileges
    echo "Warning: unable to set permissions on ${HeapDumpPath} (Operation not permitted)."
    echo "Continuing without changing ${HeapDumpPath} permissions."
  fi
  export CATALINA_OPTS="$CATALINA_OPTS -XX:HeapDumpPath=${HeapDumpPath} -XX:+HeapDumpOnOutOfMemoryError"
fi

# system property kibana can used in log4j2.xml SystemPropertyArbiter to switch to logging more specific to kibana
export CATALINA_OPTS="$CATALINA_OPTS -Dkibana=true"

# if libraries use java preferences api and sync those, avoid warnings in the log
export CATALINA_OPTS="$CATALINA_OPTS -Djava.util.prefs.userRoot=/data/prefs"

# This is unused, it is arranged in helm chart.
#export CATALINA_OUT_CMD="/usr/bin/rotatelogs -f $CATALINA_BASE/logs/catalina.out.%Y-%m-%d 86400"

CATALINA_LOGS=${CATALINA_BASE}/logs

mkdir -p /data/logs
if chmod 2775 /data/logs 2>/dev/null; then
  : # success
else
  # chmod failed; common causes: /data is a bind-mounted host dir, an NFS mount, or the process lacks privileges
  echo "Warning: unable to set permissions on /data/logs (Operation not permitted)."
  echo "Continuing without changing /data/logs permissions."
fi

# JMX
JMX_PORT=$(${CATALINA_BASE}/bin/jmx.sh)

# jmx settings
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=$JMX_PORT -Dcom.sun.management.jmxremote.rmi.port=$JMX_PORT -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false -Djava.rmi.server.hostname=localhost -Duser.country=NL -Duser.timezone=Europe/Amsterdam"

# crash logging
export CATALINA_OPTS="$CATALINA_OPTS -XX:ErrorFile=${CATALINA_LOGS}/hs_err_pid%p.log"

# this will be recognized by mmbase
export CATALINA_OPTS="${CATALINA_OPTS} -Dlog.dir=$CATALINA_BASE/logs"


if [ -z "$BodyContentImpl_BUFFER_SIZE" ] ; then
  BodyContentImpl_BUFFER_SIZE=8192
fi

# Taglib may use much memory otherwise
export CATALINA_OPTS="$CATALINA_OPTS -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true -Dorg.apache.jasper.runtime.BodyContentImpl.USE_POOL=true -Dorg.apache.jasper.runtime.BodyContentImpl.BUFFER_SIZE=${BodyContentImpl_BUFFER_SIZE}"

if [ -z "$Parser_STRICT" ] ; then
  Parser_STRICT=false
fi
if [ "$Parser_STRICT" = "true" ] ; then
  NOT_STRICT=false
else
  NOT_STRICT=true
fi


export CATALINA_OPTS="$CATALINA_OPTS -Dorg.apache.jasper.compiler.Generator.STRICT_GET_PROPERTY=${Parser_STRICT} -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=${Parser_STRICT} -Dorg.apache.jasper.compiler.Parser.STRICT_WHITESPACE=${Parser_STRICT} -Dorg.apache.el.parser.SKIP_IDENTIFIER_CHECK=${NOT_STRICT}"

# enables environmtvariable injection in tomcat config iles
export CATALINA_OPTS="$CATALINA_OPTS -Dorg.apache.tomcat.util.digester.PROPERTY_SOURCE=org.apache.tomcat.util.digester.EnvironmentPropertySource"

# enabled assertions on test.
if [ "$ENVIRONMENT" = "test" ] ; then
  CATALINA_OPTS="$CATALINA_OPTS -ea"
fi


# JPDA debugger  is arranged in catalina.sh
if [ -z "$JPDA_ADDRESS" ] ; then
  echo "Java major version=$JAVA_MAJOR"
  if [ "$JAVA_MAJOR" -gt 8 ] ; then
    export JPDA_ADDRESS="*:8000"
  else
    export JPDA_ADDRESS=8000
  fi
fi
if [ -z "$JPDA_TRANSPORT" ] ; then
  export JPDA_TRANSPORT=dt_socket
fi


# The complete container is dedicated to tomcat, so lets also use its tmp dir
export CATALINA_TMPDIR=/tmp

# note that this doesn't do anything when using catalina.sh run
export CATALINA_PID=${CATALINA_TMPDIR}/tomcat.pid


if [ -z ${TOMCAT_RELAXED_CHARS+x} ]; then  # +x: trick to check if variable is set.
  export TOMCAT_RELAXED_CHARS=''
fi

if [ -z ${TOMCAT_RELAXED_QUERY_CHARS+x} ]; then
  #export TOMCAT_RELAXED_QUERY_CHARS='[]|{}^&#x5c;&#x60;&quot;&lt;&gt;'
  export TOMCAT_RELAXED_QUERY_CHARS="$TOMCAT_RELAXED_CHARS"
fi
if [ -z ${TOMCAT_RELAXED_PATH_CHARS+x} ]; then
  export TOMCAT_RELAXED_PATH_CHARS="$TOMCAT_RELAXED_CHARS"
fi

if [ -z ${TOMCAT_ENCODED_SOLIDUS_HANDLING+x} ]; then
   export TOMCAT_ENCODED_SOLIDUS_HANDLING='passthrough'
fi

if [ -z ${TOMCAT_ACCESS_LOG_FILE_DATE_FORMAT+x} ]; then
  export TOMCAT_ACCESS_LOG_FILE_DATE_FORMAT='yyyy-MM-dd'
fi

if [ -z ${TOMCAT_CONNECTION_TIMEOUT+x} ]; then
  export TOMCAT_CONNECTION_TIMEOUT=20000
fi

if [ -z ${TOMCAT_MAX_THREADS+x} ]; then
  export TOMCAT_MAX_THREADS=400
fi

if [ -z ${TOMCAT_ASYNC_TIMEOUT+x} ]; then
  export TOMCAT_ASYNC_TIMEOUT=30000
fi

if [ -z ${TOMCAT_ACCEPT_COUNT+x} ]; then
  export TOMCAT_ACCEPT_COUNT=100
fi

if [ -z ${SCHEME+x} ]; then
  echo "No SCHEME set, setting to http"
  export SCHEME="http"
fi

if [ -z ${PROXY_PORT+x} ]; then
  echo "No PROXY_PORT set, leaving unset"
  export PROXY_PORT=""
fi

if [ -z ${PROXY_HOST+x} ]; then
  echo "No PROXY_HOST set, leaving unset"
  export PROXY_HOST=""
fi

if [ -z ${AJP_PORT+x} ]; then
   export AJP_PORT='8010'
fi



