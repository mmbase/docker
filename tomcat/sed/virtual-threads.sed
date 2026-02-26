s|<!-- THREAD POOL -->|\
  <Executor name="tomcatThreadPool" namePrefix="catalina-exec-" \
              className="org.apache.catalina.core.StandardVirtualThreadExecutor" \
              maxThreads="${TOMCAT_MAX_THREADS}" \
              minSpareThreads="2" \
              daemon="true" /> \
    />|

