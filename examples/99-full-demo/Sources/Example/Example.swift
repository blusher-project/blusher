import Blusher

import ImageResources

let lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent hendrerit augue erat, a blandit risus accumsan in. Nullam quis tortor a nisi eleifend varius. Etiam eget interdum purus. Proin lobortis aliquam pellentesque. Curabitur vestibulum nisl tellus, vitae pharetra quam tempus nec. Donec imperdiet massa sed libero consequat, ac ullamcorper mi dictum. Cras laoreet tincidunt leo quis fermentum."

let hindi = "हिंदी भाषा भारत और दुनिया भर में लाखों लोगों द्वारा बोली जाने वाली एक प्रमुख भाषा है। यह नमूना पाठ डिजाइन में हिंदी फ़ॉन्ट प्रस्तुति और टाइपोग्राफ़िक लेआउट का परीक्षण करने के लिए है। डिजाइनर इसका उपयोग देवनागरी लिपि के रेंडरिंग को सत्यापित करने के लिए कर सकते हैं।"

let arabic = "النص العربي يُكتب من اليمين إلى اليسار، وهو نظام كتابة فريد يستخدم في العديد من اللغات بما في ذلك العربية والفارسية والأردية. هذا المثال النصي يُستخدم لاختبار عرض الخطوط العربية في التصاميم والتأكد من صحة اتجاه النص. يجب على المصممين التأكد من أن المحاذاة والهوامش والأرقام تعمل بشكل صحيح في السياق العربي."

let japanese = "この文章は適当であり、特に意味などない。でももしこれが読めるならどうか自分にコーヒーを奢ってください。さらにとんこつラーメン大盛りまでごちそうされたらそれ以上の幸せはいないと思います。ちなみにこれ書いたのは夜中でした。"

@main
public struct Program {
    public static func main() {
        let app = BApplication(CommandLine.arguments)

        // Register resources.
        ImageResources.getResources().forEach {
            app.registerResource($0)
        }

        let window = MainWindow()

        let menuBar = BMenuBar(.commonMenuBarMenu, window: window)


        window.show()

        let _ = app.exec()
    }
}
