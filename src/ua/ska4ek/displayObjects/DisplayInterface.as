/**
 * Created by ska4ek.
 */
package ua.ska4ek.displayObjects {
public interface DisplayInterface {
    function removeFromParent(dispose:Boolean=false):void;
    function dispose(obj:Object):void;
    function show():void;
    function hide():void;
}
}
