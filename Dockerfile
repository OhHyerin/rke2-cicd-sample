FROM alpine:3.19
RUN echo "hello nexus" > /msg.txt
CMD ["cat","/msg.txt"]
