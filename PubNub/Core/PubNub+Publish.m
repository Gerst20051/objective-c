/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PubNub+Publish.h"
#import "PNAPICallBuilder+Private.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNConfiguration.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"
#import "PNAES.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PubNub (PublishProtected)


#pragma mark - Composite message publish

/**
 @brief      Send provided Foundation object to \b PubNub service.
 @discussion Provided object will be serialized into JSON string before pushing to \b PubNub service. If 
             client has been configured with cipher key message will be encrypted as well.
 
 @param message     Reference on Foundation object (\a NSString, \a NSNumber, \a NSArray, \a NSDictionary) 
                    which will be published.
 @param channel     Reference on name of the channel to which message should be published.
 @param payloads    Dictionary with payloads for different vendors (Apple with "apns" key and Google with 
                    "gcm").
 @param shouldStore With \c NO this message later won't be fetched with \c history API.
 @param ttl         Specify for how long message should be stored in channe's storage. If \b 0 it will be 
                    stored foreved or if \c nil - depends from account configuration.
 @param compressed  Compression useful in case if large data should be published, in another case it will lead
                    to packet size grow.
 @param replicate   Whether message should be replicated across the PubNub Real-Time Network and sent 
                    simultaneously to all subscribed clients on a channel.
 @param metadata    \b NSDictionary with values which should be used by \b PubNub service to filter messages.
 @param block       Publish processing completion block which pass only one argument - request processing 
                    status to report about how data pushing was successful or not.

 @since 4.5.4
 */
- (void)    publish:(nullable id)message toChannel:(NSString *)channel
  mobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads storeInHistory:(BOOL)shouldStore
                ttl:(nullable NSNumber *)ttl compressed:(BOOL)compressed withReplication:(BOOL)replicate 
           metadata:(nullable NSDictionary<NSString *, id> *)metadata
         completion:(nullable PNPublishCompletionBlock)block;


#pragma mark - Message helper

/**
 @brief      Helper method which allow to calculate resulting message before it will be sent to \b PubNub 
             network.
 @note       Size calculation use percent-escaped \c message and all added headers to get full size.
 
 @param message         Message for which size should be calculated.
 @param channel         Name of the channel to which message should be sent (it is part of request URI).
 @param compressMessage \c YES in case if message should be compressed before sending to \b PubNub network.
 @param shouldStore     \c NO in case if message shouldn't be available after it has been sent via history
                        storage API methods group.
 @param ttl             Specify for how long message should be stored in channe's storage. If \b 0 it will be 
                        stored foreved or if \c nil - depends from account configuration.
 @param replicate       Whether message should be replicated across the PubNub Real-Time Network and sent 
                        simultaneously to all subscribed clients on a channel.
 @param metadata        \b NSDictionary with values which should be used by \b PubNub service to filter 
                        messages.
 @param block           Reference on block which should be sent, when message size calculation will be 
                        completed.
 
 @since 4.5.4
 */
- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore ttl:(nullable NSNumber *)ttl withReplication:(BOOL)replicate 
             metadata:(nullable NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block;


#pragma mark - Handlers

/**
 @brief  Handle publish builder perform with block call.
 @note   Logic moved into separate method because it shared between two almost identical API calls (regular 
         publish and fire which doesn't store message in storage and won't replicate it).
 
 @param flags      List of conditional flags which has been generated by builder on user request.
 @param parameters List of user-provided data which will be consumed by used API endpoint.
 
 @since 4.5.4
 */
- (void)handlePublishBuilderExecutionWithFlags:(NSArray<NSString *> *)flags 
                                    parameters:(NSDictionary *)parameters;


#pragma mark - Misc

/**
 @brief  Compose set of parameters which is required to publish message.
 
 @param message         Reference on message which should be published.
 @param channel         Reference on name of the channel to which message should be published.
 @param compressMessage Whether message should be compressed before publish.
 @param replicate       Whether message should be replicated across the PubNub Real-Time Network and sent 
                        simultaneously to all subscribed clients on a channel.
 @param shouldStore     Whether message should be stored in history storage or not.
 @param ttl             Specify for how long message should be stored in channe's storage. If \b 0 it will be 
                        stored foreved or if \c nil - depends from account configuration.
 @param metadata        JSON representation of \b NSDictionary with values which should be used by \b PubNub 
                        service to filter messages.
 @param sequenceNumber  Next published message sequence number which should be used.
 
 @return Configured and ready to use request parameters instance.
 
 @since 4.0
 */
- (PNRequestParameters *)requestParametersForMessage:(NSString *)message toChannel:(NSString *)channel
                                          compressed:(BOOL)compressMessage storeInHistory:(BOOL)shouldStore 
                                                 ttl:(nullable NSNumber *)ttl replicate:(BOOL)replicate
                                            metadata:(nullable NSString *)metadata
                                      sequenceNumber:(NSUInteger)sequenceNumber;

/**
 @brief      Merge user-specified message with push payloads into single message which will be processed on
             \b PubNub service.
 @discussion In case if aside from \c message has been passed \c payloads this method will merge them into 
             format known by \b PubNub service and will cause further push distribution to specified vendors.
 
 @param message  Message which should be merged with \c payloads.
 @param payloads Dictionary with payloads for different vendors (Apple with "apns" key and Google with "gcm").
 
 @return Merged message or original message if there is no data in \c payloads.
 
 @since 4.0
 */
- (NSDictionary<NSString *, id> *)mergedMessage:(nullable id)message 
   withMobilePushPayload:(nullable NSDictionary<NSString *, id> *)payloads;

/**
 @brief  Try perform encryption of data which should be pushed to \b PubNub services.
 
 @param message Reference on data which \b PNAES should try to encrypt.
 @param key     Reference on cipher key which should be used during encryption.
 @param error   Reference on pointer into which data encryption error will be passed.
 
 @return Encrypted Base64-encoded string or original message, if there is no \c key has been passed.
         \c nil will be returned in case if encryption failed.
 
 @since 4.0
 */
- (NSString *)encryptedMessage:(NSString *)message withCipherKey:(NSString *)key
                         error:(NSError **)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (Publish)


#pragma mark - API Builder support

- (PNPublishAPICallBuilder *(^)(void))publish {
    
    PNPublishAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    builder = [PNPublishAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                   NSDictionary *parameters) {
                                     
        [weakSelf handlePublishBuilderExecutionWithFlags:flags parameters:parameters];
    }];
    
    return ^PNPublishAPICallBuilder *{ return builder; };
}

- (PNPublishAPICallBuilder *(^)(void))fire {
    
    PNPublishAPICallBuilder *builder = nil;
    __weak __typeof(self) weakSelf = self;
    builder = [PNPublishAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                   NSDictionary *parameters) {
        
        [weakSelf handlePublishBuilderExecutionWithFlags:flags parameters:parameters];
    }];
    [builder setValue:@NO forParameter:NSStringFromSelector(@selector(shouldStore))];
    [builder setValue:@NO forParameter:NSStringFromSelector(@selector(replicate))];
    
    return ^PNPublishAPICallBuilder *{ return builder; };
}

- (PNPublishSizeAPICallBuilder *(^)(void))size {
    
    PNPublishSizeAPICallBuilder *builder = nil;
    builder = [PNPublishSizeAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags,
                                                                       NSDictionary *parameters) {
                                     
        id message = parameters[NSStringFromSelector(@selector(message))];
        NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
        NSNumber *shouldStore = parameters[NSStringFromSelector(@selector(shouldStore))];
        NSNumber *ttl = parameters[NSStringFromSelector(@selector(ttl))];
        if (shouldStore && !shouldStore.boolValue) { ttl = nil; }
        NSNumber *compressed = parameters[NSStringFromSelector(@selector(compress))];
        NSNumber *replicate = parameters[NSStringFromSelector(@selector(replicate))];
        NSDictionary *metadata = parameters[NSStringFromSelector(@selector(metadata))];
        id block = parameters[@"block"];
                                         
        [self sizeOfMessage:message toChannel:channel compressed:compressed.boolValue 
             storeInHistory:(shouldStore ? shouldStore.boolValue : YES) ttl:ttl
            withReplication:(replicate ? replicate.boolValue : YES) metadata:metadata completion:block];
    }];
    
    return ^PNPublishSizeAPICallBuilder *{ return builder; };
}


#pragma mark - Plain message publish

- (void)publish:(id)message toChannel:(NSString *)channel withCompletion:(PNPublishCompletionBlock)block {

    [self publish:message toChannel:channel withMetadata:nil completion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel 
   withMetadata:(NSDictionary<NSString *, id> *)metadata completion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel compressed:NO withMetadata:metadata completion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressed
   withCompletion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel compressed:compressed withMetadata:nil completion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressed
   withMetadata:(NSDictionary<NSString *, id> *)metadata completion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel storeInHistory:YES compressed:compressed withMetadata:metadata 
       completion:block];
}

- (void) publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
  withCompletion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel storeInHistory:shouldStore withMetadata:nil completion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
   withMetadata:(NSDictionary<NSString *, id> *)metadata completion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel storeInHistory:shouldStore compressed:NO withMetadata:metadata 
       completion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
     compressed:(BOOL)compressed withCompletion:(PNPublishCompletionBlock)block {

    [self publish:message toChannel:channel storeInHistory:shouldStore compressed:compressed withMetadata:nil 
       completion:block];
}

- (void)publish:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
     compressed:(BOOL)compressed withMetadata:(NSDictionary<NSString *, id> *)metadata 
     completion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel mobilePushPayload:nil storeInHistory:shouldStore
       compressed:compressed withMetadata:metadata completion:block];
}


#pragma mark - Composite message publish

- (void)    publish:(id)message toChannel:(NSString *)channel 
  mobilePushPayload:(NSDictionary<NSString *, id> *)payloads withCompletion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel mobilePushPayload:payloads withMetadata:nil completion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary<NSString *, id> *)payloads 
       withMetadata:(NSDictionary<NSString *, id> *)metadata completion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel mobilePushPayload:payloads compressed:NO withMetadata:metadata
       completion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel 
  mobilePushPayload:(NSDictionary<NSString *, id> *)payloads compressed:(BOOL)compressed 
     withCompletion:(PNPublishCompletionBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:payloads compressed:compressed withMetadata:nil
       completion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary<NSString *, id> *)payloads compressed:(BOOL)compressed
       withMetadata:(NSDictionary<NSString *, id> *)metadata completion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:YES
       compressed:compressed withMetadata:metadata completion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary<NSString *, id> *)payloads storeInHistory:(BOOL)shouldStore
     withCompletion:(PNPublishCompletionBlock)block {

    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:shouldStore
     withMetadata:nil completion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary<NSString *, id> *)payloads storeInHistory:(BOOL)shouldStore
       withMetadata:(NSDictionary<NSString *, id> *)metadata completion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:shouldStore
       compressed:NO withMetadata:metadata completion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary<NSString *, id> *)payloads storeInHistory:(BOOL)shouldStore
         compressed:(BOOL)compressed withCompletion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:shouldStore
       compressed:compressed withMetadata:nil completion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary<NSString *, id> *)payloads storeInHistory:(BOOL)shouldStore
         compressed:(BOOL)compressed withMetadata:(NSDictionary<NSString *, id> *)metadata
         completion:(PNPublishCompletionBlock)block {
    
    [self publish:message toChannel:channel mobilePushPayload:payloads storeInHistory:shouldStore ttl:nil
       compressed:compressed withReplication:YES metadata:metadata completion:block];
}

- (void)    publish:(id)message toChannel:(NSString *)channel
  mobilePushPayload:(NSDictionary<NSString *, id> *)payloads storeInHistory:(BOOL)shouldStore
                ttl:(NSNumber *)ttl compressed:(BOOL)compressed withReplication:(BOOL)replicate 
           metadata:(NSDictionary<NSString *, id> *)metadata completion:(PNPublishCompletionBlock)block {
    
    // Get next published message sequence number and update stored data.
    NSUInteger nextSequenceNumber = [self.sequenceManager nextSequenceNumber:YES];

    // Push further code execution on secondary queue to make service queue responsive during
    // JSON serialization and encryption process.
    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t queue = (self.configuration.applicationExtensionSharedGroupIdentifier != nil ? dispatch_get_main_queue() :
                              dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_async(queue, ^{
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        BOOL encrypted = NO;
        NSError *publishError = nil;
        NSString *messageForPublish = [PNJSON JSONStringFrom:message withError:&publishError];

        // Encrypt message in case if serialization to JSON was successful.
        if (!publishError) {

            // Try perform user message encryption.
            NSString *encryptedMessage = [strongSelf encryptedMessage:messageForPublish
                                                        withCipherKey:strongSelf.configuration.cipherKey
                                                                error:&publishError];
            encrypted = ![messageForPublish isEqualToString:encryptedMessage];
            messageForPublish = [encryptedMessage copy];
        }
        
        NSString *metadataForPublish = nil;
        if (metadata) { metadataForPublish = [PNJSON JSONStringFrom:metadata withError:&publishError]; }

        // Merge user message with push notification payloads (if provided).
        if (!publishError && payloads.count) {

            NSDictionary *mergedData = [strongSelf mergedMessage:(encrypted ? messageForPublish : message)
                                           withMobilePushPayload:payloads];
            messageForPublish = [PNJSON JSONStringFrom:mergedData withError:&publishError];
        }
        PNRequestParameters *parameters = [strongSelf requestParametersForMessage:messageForPublish
                                                                        toChannel:channel 
                                                                       compressed:compressed
                                                                   storeInHistory:shouldStore ttl:ttl
                                                                        replicate:replicate
                                                                         metadata:metadataForPublish 
                                                                   sequenceNumber:nextSequenceNumber];
        
        NSData *publishData = nil;
        if (compressed) {

            NSData *messageData = [messageForPublish dataUsingEncoding:NSUTF8StringEncoding];
            NSData *compressedBody = [PNGZIP GZIPDeflatedData:messageData];
            publishData = (compressedBody?: [@"" dataUsingEncoding:NSUTF8StringEncoding]);
        }
        
        DDLogAPICall(strongSelf.logger, @"<PubNub::API> Publish%@ message to '%@' channel%@%@%@", 
                     (compressed ? @" compressed" : @""), (channel?: @"<error>"),
                     (metadata ? [NSString stringWithFormat:@" with metadata (%@)", 
                                  metadataForPublish] : @""),
                     (!shouldStore ? @" which won't be saved in history" : @""),
                     (!compressed ? [NSString stringWithFormat:@": %@",
                                     (messageForPublish?: @"<error>")] : @"."));

        [strongSelf processOperation:PNPublishOperation withParameters:parameters data:publishData
                     completionBlock:^(PNStatus *status) {
                   
           // Silence static analyzer warnings.
           // Code is aware about this case and at the end will simply call on 'nil' object method.
           // In most cases if referenced object become 'nil' it mean what there is no more need in
           // it and probably whole client instance has been deallocated.
           #pragma clang diagnostic push
           #pragma clang diagnostic ignored "-Wreceiver-is-weak"
           if (status.isError) {
                
               status.retryBlock = ^{
                   
                   [weakSelf publish:message toChannel:channel mobilePushPayload:payloads
                      storeInHistory:shouldStore compressed:compressed withMetadata:metadata
                          completion:block];
               };
           }
           [weakSelf callBlock:block status:YES withResult:nil andStatus:status];
           #pragma clang diagnostic pop
       }];
    });
}


#pragma mark - Message helper

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel withMetadata:nil completion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel compressed:NO withMetadata:metadata completion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel compressed:compressMessage withMetadata:nil 
             completion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel compressed:compressMessage storeInHistory:YES
           withMetadata:metadata completion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
       withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel storeInHistory:shouldStore withMetadata:nil
             completion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel storeInHistory:(BOOL)shouldStore
         withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel compressed:NO storeInHistory:shouldStore
           withMetadata:metadata completion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore withCompletion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel compressed:compressMessage storeInHistory:shouldStore
           withMetadata:nil completion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore withMetadata:(NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block {
    
    [self sizeOfMessage:message toChannel:channel compressed:compressMessage storeInHistory:shouldStore
                    ttl:nil withReplication:YES metadata:metadata completion:block];
}

- (void)sizeOfMessage:(id)message toChannel:(NSString *)channel compressed:(BOOL)compressMessage
       storeInHistory:(BOOL)shouldStore ttl:(NSNumber *)ttl withReplication:(BOOL)replicate 
             metadata:( NSDictionary<NSString *, id> *)metadata
           completion:(PNMessageSizeCalculationCompletionBlock)block {
    
    if (block) {
        
        // Get next published message sequence number.
        NSUInteger nextSequenceNumber = [self.sequenceManager nextSequenceNumber:NO];
        
        // Push further code execution on secondary queue to make service queue responsive during
        // JSON serialization and encryption process.
        __weak __typeof(self) weakSelf = self;
        dispatch_queue_t queue = (self.configuration.applicationExtensionSharedGroupIdentifier != nil ? dispatch_get_main_queue() :
                                  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_async(queue, ^{
            
            NSError *publishError = nil;
            NSString *messageForPublish = [PNJSON JSONStringFrom:message withError:&publishError];
            // Silence static analyzer warnings.
            // Code is aware about this case and at the end will simply call on 'nil' object method.
            // In most cases if referenced object become 'nil' it mean what there is no more need in
            // it and probably whole client instance has been deallocated.
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wreceiver-is-weak"
            #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
            // Encrypt message in case if serialization to JSON was successful.
            if (!publishError) {
                
                // Try perform user message encryption.
                messageForPublish = [self encryptedMessage:messageForPublish
                                             withCipherKey:self.configuration.cipherKey
                                                     error:&publishError];
            }
            
            NSString *metadataForPublish = nil;
            if (metadata) { metadataForPublish = [PNJSON JSONStringFrom:metadata withError:&publishError]; }
            
            PNRequestParameters *parameters = [self requestParametersForMessage:messageForPublish
                                                                      toChannel:channel
                                                                     compressed:compressMessage
                                                                 storeInHistory:shouldStore ttl:ttl
                                                                      replicate:replicate
                                                                       metadata:metadataForPublish 
                                                                 sequenceNumber:nextSequenceNumber];
            NSData *publishData = nil;
            if (compressMessage) {
                
                NSData *messageData = [messageForPublish dataUsingEncoding:NSUTF8StringEncoding];
                NSData *compressedBody = [PNGZIP GZIPDeflatedData:messageData];
                publishData = (compressedBody?: [@"" dataUsingEncoding:NSUTF8StringEncoding]);
            }
            NSInteger size = [weakSelf packetSizeForOperation:PNPublishOperation
                                               withParameters:parameters data:publishData];
            pn_dispatch_async(weakSelf.callbackQueue, ^{
                
                block(size);
            });
            #pragma clang diagnostic pop
        });
    }
}


#pragma mark - Handlers

- (void)handlePublishBuilderExecutionWithFlags:(NSArray<NSString *> *)flags 
                                    parameters:(NSDictionary *)parameters {
    
    id message = parameters[NSStringFromSelector(@selector(message))];
    NSString *channel = parameters[NSStringFromSelector(@selector(channel))];
    NSDictionary *payloads = parameters[NSStringFromSelector(@selector(payloads))];
    NSNumber *shouldStore = parameters[NSStringFromSelector(@selector(shouldStore))];
    NSNumber *ttl = parameters[NSStringFromSelector(@selector(ttl))];
    if (shouldStore && !shouldStore.boolValue) { ttl = nil; }
    NSNumber *compressed = parameters[NSStringFromSelector(@selector(compress))];
    NSNumber *replicate = parameters[NSStringFromSelector(@selector(replicate))];
    NSDictionary *metadata = parameters[NSStringFromSelector(@selector(metadata))];
    id block = parameters[@"block"];
    
    [self publish:message toChannel:channel mobilePushPayload:payloads 
   storeInHistory:(shouldStore ? shouldStore.boolValue : YES) ttl:ttl compressed:compressed.boolValue
  withReplication:(replicate ? replicate.boolValue : YES) metadata:metadata completion:block];
}


#pragma mark - Misc

- (PNRequestParameters *)requestParametersForMessage:(NSString *)message toChannel:(NSString *)channel
                                          compressed:(BOOL)compressMessage storeInHistory:(BOOL)shouldStore 
                                                 ttl:(NSNumber *)ttl replicate:(BOOL)replicate
                                            metadata:(NSString *)metadata
                                      sequenceNumber:(NSUInteger)sequenceNumber {
    
    PNRequestParameters *parameters = [PNRequestParameters new];
    if (channel.length) {
        
        [parameters addPathComponent:[PNString percentEscapedString:channel] forPlaceholder:@"{channel}"];
    }
    if (!shouldStore) { [parameters addQueryParameter:@"0" forFieldName:@"store"]; }
    if (ttl) { [parameters addQueryParameter:ttl.stringValue forFieldName:@"ttl"]; }
    if (!replicate) { [parameters addQueryParameter:@"true" forFieldName:@"norep"]; }
    if (([message isKindOfClass:[NSString class]] && message.length) || message) {
        
        [parameters addPathComponent:(!compressMessage ? [PNString percentEscapedString:message] : @"")
                      forPlaceholder:@"{message}"];
    }
    
    if ([metadata isKindOfClass:[NSString class]] && metadata.length) {
        
        [parameters addQueryParameter:[PNString percentEscapedString:metadata] forFieldName:@"meta"];
    }
    
    [parameters addQueryParameter:@(sequenceNumber).stringValue forFieldName:@"seqn"];
    
    return parameters;
}

- (NSDictionary<NSString *, id> *)mergedMessage:(id)message
   withMobilePushPayload:(NSDictionary<NSString *, id> *)payloads {

    // Convert passed message to mutable dictionary into which required by push notification
    // delivery service provider data will be added.
    NSDictionary *originalMessage =  (!message ? @{} : ([message isKindOfClass:[NSDictionary class]] ?
                                                        message : @{@"pn_other":message}));
    NSMutableDictionary *mergedMessage = [originalMessage mutableCopy];
    for (NSString *pushProviderType in payloads) {

        id payload = payloads[pushProviderType];
        NSString *providerKey = pushProviderType;
        if (![pushProviderType hasPrefix:@"pn_"]) {
            
            providerKey = [NSString stringWithFormat:@"pn_%@", pushProviderType];
            if ([pushProviderType isEqualToString:@"aps"]) {
                
                payload = @{pushProviderType:payload};
                providerKey = @"pn_apns";
            }
        }
        [mergedMessage setValue:payload forKey:providerKey];
    }
    
    return [mergedMessage copy];
}

- (NSString *)encryptedMessage:(NSString *)message withCipherKey:(NSString *)key
                         error:(NSError *__autoreleasing *)error {
    
    NSString *encryptedMessage = message;
    if (key.length) {
        
        NSData *JSONData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSString *JSONString = [PNAES encrypt:JSONData withKey:key andError:error];
        if (*error == nil) {
            
            // PNAES encryption output is NSString which is valid JSON object from PubNub
            // service perspective, but it should be decorated with " (this done internally
            // by helper when it need to create JSON string).
            encryptedMessage = [PNJSON JSONStringFrom:JSONString withError:error];
        }
        else { encryptedMessage = nil; }
    }
    
    return encryptedMessage;
}

#pragma mark -


@end
