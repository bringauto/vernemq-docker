FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get -y install git bash procps openssl libssl-dev iproute2 curl jq libsnappy-dev net-tools erlang build-essential vim && \
    rm -rf /var/lib/apt/lists/* && \
    addgroup --gid 1000 vernemq && \
    adduser --uid 1000 --system --ingroup vernemq --home /vernemq --disabled-password vernemq

RUN git clone https://github.com/bringauto/vernemq /vernemq_build && \
    cd /vernemq_build && \
    git checkout 1.13.0 && \
    make rel && \
    cp -r /vernemq_build/_build/default/rel/vernemq/* /vernemq && \
    rm -rf /vernemq_build && \
    chown -R vernemq:vernemq /vernemq

RUN apt-get purge -y erlang git jq build-essential libssl-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=1000:1000 script/vernemq_run.sh /vernemq/vernemq_run.sh
COPY --chown=1000:1000 config/vernemq.conf /etc/vernemq/vernemq.conf
COPY --chown=1000:1000 config/vmq.acl /etc/vernemq/vmq.acl

RUN chmod +x /vernemq/vernemq_run.sh && \
    chown -R vernemq:vernemq /vernemq && \
    chown -R vernemq:vernemq /etc/vernemq && \
    rm -rf /vernemq/etc && \
    ln -s /etc/vernemq /vernemq/etc

EXPOSE 1883 8883

USER vernemq

CMD ["/vernemq/vernemq_run.sh"]