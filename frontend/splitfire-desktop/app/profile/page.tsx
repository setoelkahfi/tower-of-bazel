import { SkeletonCard } from '../_ui/skeleton-card';

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
  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="max-w-none">
        Your profile
      </div>
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <h2 className="text-2xl font-bold">Your plays</h2>
        {Array.from({ length: 6 }).map((_, i) => (
          <SkeletonCard key={i} />
        ))}
      </div>
    </div>
  );
}
