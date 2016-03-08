/*
################################################################################
#  THIS FILE IS 100% GENERATED BY ZPROJECT; DO NOT EDIT EXCEPT EXPERIMENTALLY  #
#  Please refer to the README for information about making permanent changes.  #
################################################################################
*/

#include "QmlZtrie.h"


///
//  Inserts a new route into the tree and attaches the data. Returns -1     
//  if the route already exists, otherwise 0. This method takes ownership of
//  the provided data if a destroy_data_fn is provided.                     
int QmlZtrie::insertRoute (const QString &path, void *data, ztrie_destroy_data_fn destroyDataFn) {
    return ztrie_insert_route (self, path.toUtf8().data(), data, destroyDataFn);
};

///
//  Removes a route from the trie and destroys its data. Returns -1 if the
//  route does not exists, otherwise 0.                                   
//  the start of the list call zlist_first (). Advances the cursor.       
int QmlZtrie::removeRoute (const QString &path) {
    return ztrie_remove_route (self, path.toUtf8().data());
};

///
//  Returns true if the path matches a route in the tree, otherwise false.
bool QmlZtrie::matches (const QString &path) {
    return ztrie_matches (self, path.toUtf8().data());
};

///
//  Returns the data of a matched route from last ztrie_matches. If the path
//  did not match, returns NULL. Do not delete the data as it's owned by    
//  ztrie.                                                                  
void *QmlZtrie::hitData () {
    return ztrie_hit_data (self);
};

///
//  Returns the count of parameters that a matched route has.
size_t QmlZtrie::hitParameterCount () {
    return ztrie_hit_parameter_count (self);
};

///
//  Returns the parameters of a matched route with named regexes from last   
//  ztrie_matches. If the path did not match or the route did not contain any
//  named regexes, returns NULL.                                             
QmlZhashx *QmlZtrie::hitParameters () {
    QmlZhashx *retQ_ = new QmlZhashx ();
    retQ_->self = ztrie_hit_parameters (self);
    return retQ_;
};

///
//  Returns the asterisk matched part of a route, if there has been no match
//  or no asterisk match, returns NULL.                                     
const QString QmlZtrie::hitAsteriskMatch () {
    return QString (ztrie_hit_asterisk_match (self));
};

///
//  Print the trie
void QmlZtrie::print () {
    ztrie_print (self);
};


QObject* QmlZtrie::qmlAttachedProperties(QObject* object) {
    return new QmlZtrieAttached(object);
}


///
//  Self test of this class.
void QmlZtrieAttached::test (bool verbose) {
    ztrie_test (verbose);
};

///
//  Creates a new ztrie.
QmlZtrie *QmlZtrieAttached::construct (char delimiter) {
    QmlZtrie *qmlSelf = new QmlZtrie ();
    qmlSelf->self = ztrie_new (delimiter);
    return qmlSelf;
};

///
//  Destroy the ztrie.
void QmlZtrieAttached::destruct (QmlZtrie *qmlSelf) {
    ztrie_destroy (&qmlSelf->self);
};

/*
################################################################################
#  THIS FILE IS 100% GENERATED BY ZPROJECT; DO NOT EDIT EXCEPT EXPERIMENTALLY  #
#  Please refer to the README for information about making permanent changes.  #
################################################################################
*/
