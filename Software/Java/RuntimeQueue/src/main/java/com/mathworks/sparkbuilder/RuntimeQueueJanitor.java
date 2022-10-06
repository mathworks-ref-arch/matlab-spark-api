package com.mathworks.sparkbuilder;

import java.util.TimerTask;

public class RuntimeQueueJanitor extends TimerTask {

    
    @Override
    public void run() {
        RuntimeQueue.log("RuntimeQueueJanitor started.");

        RuntimeQueue rtQueue = RuntimeQueue.getSingleton();

        rtQueue.cleanupQueue(30L);

        RuntimeQueue.log("RuntimeQueueJanitor finished.");


    }
}
