/*
################################################################################
#  THIS FILE IS 100% GENERATED BY ZPROJECT; DO NOT EDIT EXCEPT EXPERIMENTALLY  #
#  Please refer to the README for information about making permanent changes.  #
################################################################################
*/
#ifndef Q_ZSTR_H
#define Q_ZSTR_H

#include "qczmq.h"

class QT_CZMQ_EXPORT QZstr : public QObject
{
    Q_OBJECT
public:

    //  Copy-construct to return the proper wrapped c types
    QZstr (zstr_t *self, QObject *qObjParent = 0);

    //  Receive C string from socket. Caller must free returned string using
    //  zstr_free(). Returns NULL if the context is being terminated or the 
    //  process was interrupted.                                            
    static QString recv (void *source);

    //  Send a C string to a socket, as a frame. The string is sent without 
    //  trailing null byte; to read this you can use zstr_recv, or a similar
    //  method that adds a null terminator on the received string. String   
    //  may be NULL, which is sent as "".                                   
    static int send (void *dest, const QString &string);

    //  Send a C string to a socket, as zstr_send(), with a MORE flag, so that
    //  you can send further strings in the same multi-part message.          
    static int sendm (void *dest, const QString &string);

    //  Send a formatted string to a socket. Note that you should NOT use
    //  user-supplied strings in the format (they may contain '%' which  
    //  will create security holes).                                     
    static int sendf (void *dest, const QString &param);

    //  Send a formatted string to a socket, as for zstr_sendf(), with a      
    //  MORE flag, so that you can send further strings in the same multi-part
    //  message.                                                              
    static int sendfm (void *dest, const QString &param);

    //  Accepts a void pointer and returns a fresh character string. If source
    //  is null, returns an empty string.                                     
    static QString str (void *source);

    //  Self test of this class.
    static void test (bool verbose);

    zstr_t *self;
};
#endif //  Q_ZSTR_H
/*
################################################################################
#  THIS FILE IS 100% GENERATED BY ZPROJECT; DO NOT EDIT EXCEPT EXPERIMENTALLY  #
#  Please refer to the README for information about making permanent changes.  #
################################################################################
*/
