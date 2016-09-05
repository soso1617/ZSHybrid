/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

var zshybrid = zshybrid || {};

(function() 
{
    //
    //  default scheme for mobile app aware
    //
    var hybridScheme = "hybridsample";
    var hybridCalls = hybridCalls || {};

    //
    //  fetch parameter strings, format will be p1=xxx&p2=xxx&p3=xxx
    //  iOS client will call this method directly and get the return value
    //  Android client will create a java interface and set this function as that interface parameter
    //  eg. javaAPI(parameter){//do something}; javaAPI(zshybrid.fetchParameter(callID));
    //
    this.fetchParameter = function(callID)
    {
        var parameter = hybridCalls[callID].parameter;

        if (!hybridCalls[callID].sCallback && !hybridCalls[callID].fCallback) 
        {
            //
            //  delete this call if this call no callbacks
            //
            delete hybridCalls[callID];
        }

        return parameter;
    }

    //
    //  callback from native client
    //
    this.callbackFromMobile = function(callID, parameter, successFlag)
    {
        if (successFlag && hybridCalls[callID].sCallback) 
        {
            hybridCalls[callID].sCallback.call(null, parameter);
        }
        else if (!successFlag && hybridCalls[callID].fCallback) 
        {
            hybridCalls[callID].fCallback.call(null, parameter);
        }

        //
        //  delete this call after callback?
        //
        delete hybridCalls[callID];
    }

    //
    //  invoke native interface
    //
    this.invokeMobileWithCallbackFunctions = function(mobileFunctionName, parameter, sCallback, fCallback)
    {
        if(mobileFunctionName)
        {
            var callID = "zshybrid" + (Math.floor(Math.random() * 10000) + 1);

            //
            //  prevent override exsiting one
            //
            while (hybridCalls[callID])
            {
                callID = "zshybrid" + (Math.floor(Math.random() * 10000) + 1);
            }

            var oneCall = 
            {
                mobileFunctionName:mobileFunctionName,
                parameter:parameter,
                sCallback:sCallback,
                fCallback:fCallback,
                callID:callID
            };

            hybridCalls[callID] = oneCall;

            var url = hybridScheme + "://"+ mobileFunctionName + "/?callID=" + callID;

            window.open(url, "_self");
        }
    }

    //
    //  change scheme if need
    //
    this.registerSchemeForApplication = function(scheme)
    {
        hybridScheme = scheme;
    }

}).apply(zshybrid)

