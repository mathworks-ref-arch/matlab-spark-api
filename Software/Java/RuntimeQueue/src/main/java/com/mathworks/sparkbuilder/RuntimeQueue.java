
package com.mathworks.sparkbuilder;

import com.mathworks.toolbox.javabuilder.MWApplication;
import com.mathworks.toolbox.javabuilder.MWMCROption;
import com.mathworks.toolbox.javabuilder.internal.MWComponentInstance;
import com.mathworks.toolbox.javabuilder.MWCtfExtractLocation;
import com.mathworks.toolbox.javabuilder.MWException;
import com.mathworks.toolbox.javabuilder.MWCtfClassLoaderSource;
import com.mathworks.toolbox.javabuilder.MWComponentOptions;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Iterator;
import java.util.Timer;

// Constructing class dynamically
// Class<?> cl = Class.forName("javax.swing.JLabel");
// Constructor<?> cons = cl.getConstructor(String.class);

// // The call to getConstructor specifies that you want the constructor that takes a single String parameter. Now to create an instance:

// Object o = cons.newInstance("JLabel");

public class RuntimeQueue {
    private int poolSize = 0;
    private int slotsUsed = 0;
    private boolean debugOn = false;
    private static RuntimeQueue singleton = null;
    private static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss,SSS");

    // Maybe needs to be
    // ArrayBlockingQueue<MWComponentInstance<?>> pool = null;
    ArrayBlockingQueue<RuntimeEntry> pool = null;
    private Timer janitorialTimer;

    public static synchronized RuntimeQueue getSingleton(boolean dbgOn) {
        return RuntimeQueue.getSingleton(Runtime.getRuntime().availableProcessors(), dbgOn);
    }

    public static synchronized RuntimeQueue getSingleton() {
        return RuntimeQueue.getSingleton(Runtime.getRuntime().availableProcessors(), false);
    }

    public static synchronized RuntimeQueue getSingleton(int poolSize_) {
        return RuntimeQueue.getSingleton(poolSize_, false);
    }

    public static synchronized RuntimeQueue getSingleton(int poolSize_, boolean dbgOn) {
        if (RuntimeQueue.singleton == null) {
            RuntimeQueue.singleton = new RuntimeQueue(poolSize_, dbgOn);
        }
        return RuntimeQueue.singleton;
    }

    private RuntimeQueue(int poolSize_, boolean dbgOn) {
        // The next call changes a setting that will make the Runtime be created out of
        // process. It must be the
        // first call to the runtime, before any application is initialized.
        poolSize = poolSize_;
        debugOn = dbgOn;

        MWApplication.initialize(MWMCROption.OUTPROC);

        pool = new ArrayBlockingQueue<RuntimeEntry>(poolSize);
        if (debugOn) {
            showStatus();
        }

        // Create a Timer in daemon state
        janitorialTimer = new Timer(true);

        // Run the janitor service every 20 seconds.
        janitorialTimer.schedule(new RuntimeQueueJanitor(), 20L * 1000L, 20L *
        1000L);

    }

    private void disposeEntry(RuntimeEntry entry) {
        try {
            entry.instance.dispose();
            slotsUsed--;
            if (debugOn) {
                log("Disposed of " + entry.instance);
            }
        } catch (Exception ex) {
            // The exception is really a MWException, but the compiler doesn't see that.
            ex.printStackTrace();
            log("Failed to dispose of runtime. Just assuming it's dead.");
        }
    }

    /**
     * Function: cleanupQueue
     * Cleans up the queue of entries that have spent more than a certain amount
     * of time there
     * 
     * @param seconds The number of seconds that is considered too old to keep
     */
    public void cleanupQueue(Long seconds) {
        synchronized (this) {
            int sz = pool.size();
            for (int k = 0; k < sz; k++) {
                RuntimeEntry candidate = null;
                try {
                    candidate = pool.take();
                    if (candidate.age() > seconds) {
                        if (debugOn) {
                            log("Candidate #" + k + " " + candidate + " is past its age, disposing.");
                        }
                        disposeEntry(candidate);
                    } else {
                        if (debugOn) {
                            log("Candidate #" + k + " " + candidate + " is not too old, keeping.");
                        }
                        pool.put(candidate);
                    }
                } catch (InterruptedException ex) {
                    log("Interrupted while trying to get an element from the pool");
                    ex.printStackTrace();
                }
            }
        }
    }

    private MWComponentInstance<?> createInstance(Class<?> clazz, Class<?> factoryClazz) {

        try {
            String runtimeClassName = clazz.toString();
            if (debugOn) {
                log("Trying to create an instance of " + runtimeClassName);
            }
            Class<?> argClass = Class.forName("com.mathworks.toolbox.javabuilder.MWComponentOptions");
            java.lang.reflect.Constructor<?> constructor = clazz.getConstructor(argClass);

            String uuid = java.util.UUID.randomUUID().toString();
            String ctfRoot = "/tmp/ctfroot_" + uuid;
            MWCtfExtractLocation mwctfExt = new MWCtfExtractLocation(ctfRoot);
            MWComponentOptions mwCompOpts = new MWComponentOptions(mwctfExt,
                    new MWCtfClassLoaderSource(factoryClazz));
            MWComponentInstance<?> elem = (MWComponentInstance<?>) constructor.newInstance(mwCompOpts);

            // Increase the count of used slots
            slotsUsed++;
            if (debugOn) {
                log("Created an instance of " + runtimeClassName);
            }
            return elem;

            // } catch (MWException mwex) {
        } catch (Exception mwex) {
            // Using plain exception, as the reflection seems to hide what is thrown
            mwex.printStackTrace();
            System.err.println("MWException during creation of runtime instance: " + mwex.toString());
        }
        return null;
    }

    private MWComponentInstance<?> useOrDispose(RuntimeEntry entry, Class<?> clazz,
            Class<?> factoryClazz) {
        String runtimeClassName = clazz.toString();
        if (debugOn) {
            log("useOrDispose for " + runtimeClassName + ", existing entry is " + entry);
        }
        if (entry.runtimeClassName.equals(runtimeClassName)) {
            if (debugOn) {
                log("It's a match, use candidate" + entry.instance);
            }
            return entry.instance;
        } else {
            if (debugOn) {
                log("Not a match, dispose of " + entry.instance);
            }
            disposeEntry(entry);
            return createInstance(clazz, factoryClazz);
        }
    }

    public MWComponentInstance<?> getInstance(Class<?> clazz, Class<?> factoryClazz) {
        synchronized (this) {
            String runtimeClassName = clazz.toString();
            MWComponentInstance<?> inst = null;
            try {
                if (debugOn) {
                    log("Trying to get instance for " + runtimeClassName);
                    showStatus();
                }
                // Pseudo code describing the algorithm of this method
                if (pool.size() == 0) {
                    if (debugOn) {
                        log("No entries in pool");
                    }
                    if (slotsUsed == poolSize) {
                        // Pool is empty, but no slots available.
                        // Take one instance. If it's the correct type, use it.
                        // If it's not the correct type, dispose of it, and create the
                        // correct type
                        if (debugOn) {
                            log("All pool slots assigned, waiting for something to be returned");
                        }
                        // This is a blocking call
                        RuntimeEntry entry = pool.take();
                        return useOrDispose(entry, clazz, factoryClazz);
                    } else {
                        // Pool is empty, but there are slots available
                        // Just create a new one.
                        if (debugOn) {
                            log("There are still pool slots free, just create an instance");
                        }
                        inst = createInstance(clazz, factoryClazz);
                        return inst;
                    }
                } else {
                    // Iterate over the elements to see if we find a suitable candidate
                    // If we find a candidate, use it.
                    // If none is available, there are two options.
                    // If a slot is still free, just create an instance of the right type.
                    // If no slots are free, just take the head of the queue, dispose of it, and
                    // create a new one.
                    if (debugOn) {
                        log("There are unused entries in the pool. Loop through them to find a suitable candidate");
                    }
                    int sz = this.pool.size();
                    for (int k = 0; k < sz; k++) {
                        RuntimeEntry candidate = pool.take();
                        if (candidate.runtimeClassName.equals(runtimeClassName)) {
                            inst = candidate.instance;
                            if (debugOn) {
                                log("Candidate #" + k + " is suitable. " + candidate + " Using this.");
                            }
                            return inst;
                        } else {
                            if (debugOn) {
                                log("Candidate #" + k + " is not suitable. " + candidate + " Returning to pool.");
                            }
                            pool.put(candidate);
                        }
                    }

                    // If we get here, nothing was in the pool.
                    if (slotsUsed == poolSize) {
                        // All slots are used. Wait for a free slot
                        RuntimeEntry entry = pool.take();
                        return useOrDispose(entry, clazz, factoryClazz);
                    } else {
                        // Not all slots are used. Just create a new entry
                        inst = createInstance(clazz, factoryClazz);
                        return inst;
                    }
                }
            } catch (InterruptedException iex) {
                iex.printStackTrace();
                System.err.println("Problem with Runtime Queue: " + iex.toString());
            }

            return null;
        }
    } /* getInstance */

    public void releaseInstance(MWComponentInstance<?> inst, Class<?> clazz) {

        synchronized (this) {
            String runtimeClassName = clazz.toString();
            if (debugOn) {
                log("Returning instance " + inst + " to the pool.");
            }
            if (inst != null) {
                try {
                    RuntimeEntry entry = new RuntimeEntry(inst, runtimeClassName);
                    pool.put(entry);
                } catch (InterruptedException iex) {
                    iex.printStackTrace();
                    System.err.println("Problem with Runtime Queue: " + iex.toString());
                }
            }
        }
    } /* releaseInstance */

    public void showStatus() {
        synchronized (this) {
            log(
                    "RuntimeQueue instance -" +
                            "debugOn:" + debugOn + " " +
                            "poolSize:" + poolSize + " " +
                            "size:" + pool.size() + " " +
                            "slotsUsed:" + slotsUsed);

            Iterator<RuntimeEntry> iter = pool.iterator();
            int idx = 0;
            while (iter.hasNext()) {
                RuntimeEntry entry = iter.next();
                log("Entry #" + idx + ": " + entry);
                idx++;
            }
        }
    } /* showStatus */

    public long getRuntimeCountOnNode() {
        long count = -1L;
        String[] commands = { "/bin/sh", "-c", "ps -ef | grep \"[c]tfserver\"" };
        try {
            Process proc = Runtime.getRuntime().exec(commands);
            java.io.BufferedReader br = new java.io.BufferedReader(
                    new java.io.InputStreamReader(proc.getInputStream()));
            count = br.lines().count();
        } catch (java.io.IOException ioex) {
            ioex.printStackTrace();
        }
        return count;
    }

    public static void log(String msg) {
        long now = System.currentTimeMillis();
        String nowDateStr = sdf.format(new Date(now));
        String hostInfo;
        String threadString = "0x" + Integer.toHexString(Thread.currentThread().hashCode());
        try {
            hostInfo = java.net.InetAddress.getLocalHost().toString();
        } catch (java.net.UnknownHostException uhex) {
            hostInfo = "UNKNOWN_HOST_ISSUE";
        }
        System.out.println(nowDateStr + " (SB) " + hostInfo + " " + threadString + " " + msg);
    }

    public static long tic(String msg) {
        log("Starting " + msg);
        long lastTic = System.currentTimeMillis();
        return lastTic;
    }

    public static void toc(String msg, long lastTic) {
        long now = System.currentTimeMillis();
        long elapsedL = now - lastTic;
        double elapsed = (double) elapsedL / 1000.0;
        log("Finished " + msg + " " + elapsed + " sec");
    }

} /* class RuntimeQueue */
