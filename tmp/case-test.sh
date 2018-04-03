#!/bin/bash
function="lsa"
case "$1" in
     start)
          case "$function" in
               ls)
                    ls
                    ;;
               lsa)
                    ls -lah
                    ;;
          esac
          ;;
esac
