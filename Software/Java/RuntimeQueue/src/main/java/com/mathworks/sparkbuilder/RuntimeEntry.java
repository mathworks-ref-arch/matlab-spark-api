package com.mathworks.sparkbuilder;

import com.mathworks.toolbox.javabuilder.internal.MWComponentInstance;

public class RuntimeEntry {
    public MWComponentInstance<?> instance;
    public String runtimeClassName;
    public Long insertTime;

    public RuntimeEntry(MWComponentInstance<?> inst, String className) {
        this.instance = inst;
        this.runtimeClassName = className;
        this.insertTime = System.currentTimeMillis();
    }

    /** age
     * Returns the age in seconds, counted in wall clock time,
     * of this component.
     * 
     * @return A Long containing the age in seconds.
     */
    public Long age() {
        Long now = System.currentTimeMillis();
        Long elapsed = now - this.insertTime;
        Long elapsedSeconds = elapsed / 1000;
        return elapsedSeconds;
    }

    public String toString() {
        return this.instance.toString() + " - Age " + age() + " sec.";
    }
};
