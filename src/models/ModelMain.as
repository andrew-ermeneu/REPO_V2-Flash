/**
 * Created by zip on 4/8/14.
 */
package models {
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;




public class ModelMain extends EventDispatcher {

    private static var _instance: ModelMain;


    public var id:String;
    public var token:String;
    public var device_udid:String;

    public const device_name:String = "FlashPlayer";
    public const device_type:String = "blackbox";
    public const device_description:String = "Descr for flash player";

    public var username:String = Config.DEFAULT_USERNAME;
    public var password:String = Config.DEFAULT_PASSWORD;


    public var userid:String;
    public var custid:String;




    public function ModelMain(p_key: ModelMainBlocker, target:IEventDispatcher = null) {

        super(target);

        if (p_key == null) {
            throw new Error("Error: Instantiation failed: Use ModelMain.getInstance() instead of new.");
        } else {

            id = Math.random() + "_" + new Date().getTime();
            device_udid = Math.random() + "_" + new Date().getTime();
        }
    }





    static public function getInstance(): ModelMain {
        if (_instance == null) {
            _instance = new ModelMain(new ModelMainBlocker());
        }
        return _instance;

    }











}

}
internal class ModelMainBlocker {
}
