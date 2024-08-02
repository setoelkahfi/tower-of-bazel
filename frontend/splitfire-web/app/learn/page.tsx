import Footer from "../_components/footer";
import Header from "../_components/header";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <Header />
      <div className="relative z-[-1] before:absolute before:h-[300px] before:w-full before:-translate-x-1/2 before:rounded-full before:bg-gradient-radial before:from-white before:to-transparent before:blur-2xl before:content-[''] after:absolute after:-z-20 after:h-[180px] after:w-full after:translate-x-1/3 after:bg-gradient-conic after:from-sky-200 after:via-blue-200 after:blur-2xl after:content-[''] before:dark:bg-gradient-to-br before:dark:from-transparent before:dark:to-blue-700 before:dark:opacity-10 after:dark:from-sky-900 after:dark:via-[#0141ff] after:dark:opacity-40 sm:before:w-[480px] sm:after:w-[240px] before:lg:h-[360px]">
        <h1 className="text-6xl text-transparent bg-clip-text bg-gradient-to-br from-sky-500 to-blue-500 dark:from-sky-900 dark:to-blue-900 sm:text-8xl">
          Learn!
        </h1>
        <ul>
          <li>Start learning.</li>
          <li>Start practicing.</li>
          <li>Start playing.</li>
        </ul>
      </div>

      <Footer />
    </main>
  );
}