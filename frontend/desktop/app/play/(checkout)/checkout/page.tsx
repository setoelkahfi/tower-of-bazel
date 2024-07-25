export async function generateStaticParams() {
  const posts = [
    { slug: "post-1" },
    { slug: "post-2" },
    { slug: "post-3" },
  ];
 
  return posts.map((post) => ({
    slug: post.slug,
  }))
}

export default function Page() {
  return <h1 className="text-xl font-medium text-gray-400/80">Checkout</h1>;
}
